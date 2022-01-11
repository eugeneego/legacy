//
// UrlSessionHttp
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class UrlSessionHttp: Http {
    public let session: URLSession
    public let responseQueue: DispatchQueue

    open var trustPolicies: [String: ServerTrustPolicy] {
        get { delegateObject.trustPolicies }
        set { delegateObject.trustPolicies = newValue }
    }

    private let delegateObject: Delegate

    private let logger: UrlSessionHttpLogger?

    public init(
        configuration: URLSessionConfiguration,
        responseQueue: DispatchQueue,
        trustPolicies: [String: ServerTrustPolicy] = [:],
        logger: UrlSessionHttpLogger? = nil
    ) {
        self.responseQueue = responseQueue
        self.logger = logger
        delegateObject = Delegate(responseQueue: responseQueue, trustPolicies: trustPolicies)
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: delegateObject.queue)
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Request

    open func data(request: URLRequest) -> HttpDataTask {
        let dataTask = session.dataTask(with: request)
        let task = DataTask(task: dataTask, request: request, queue: responseQueue, logger: logger)
        delegateObject.add(task: task)
        return task
    }

    open func download(request: URLRequest, destination: URL) -> HttpDownloadTask {
        let downloadTask = session.downloadTask(with: request)
        let task = DownloadTask(task: downloadTask, destination: destination, request: request, queue: responseQueue, logger: logger)
        delegateObject.add(task: task)
        return task
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    open func data(request: URLRequest) async -> HttpResult<Data> {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            do {
                let data = try await session.data(for: request)
                return Routines.process(response: data.1, data: data.0, error: nil)
            } catch {
                return Routines.process(response: nil, data: nil, error: error)
            }
        } else {
            let task = TaskActor()
            return await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation { continuation in
                        Task {
                            await task.resume(task: session.dataTask(with: request) { data, response, error in
                                let result = Routines.process(response: response, data: data, error: error)
                                continuation.resume(returning: result)
                            })
                        }
                    }
                },
                onCancel: {
                    Task {
                        await task.cancel()
                    }
                }
            )
        }
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    open func download(request: URLRequest, destination: URL) async -> HttpResult<URL> {
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            do {
                let data = try await session.download(for: request)
                var result = Routines.process(response: data.1, data: data.0, error: nil)
                result = Routines.moveFile(result: result, destination: destination)
                return Routines.process(response: data.1, data: data.0, error: nil)
            } catch {
                return Routines.process(response: nil, data: nil, error: error)
            }
        } else {
            let task = TaskActor()
            return await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation { continuation in
                        Task {
                            await task.resume(task: session.downloadTask(with: request) { url, response, error in
                                var result = Routines.process(response: response, data: url, error: error)
                                result = Routines.moveFile(result: result, destination: destination)
                                continuation.resume(returning: result)
                            })
                        }
                    }
                },
                onCancel: {
                    Task {
                        await task.cancel()
                    }
                }
            )
        }
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    private actor TaskActor {
        weak var task: URLSessionTask?

        func resume(task: URLSessionTask) {
            self.task = task
            task.resume()
        }

        func cancel() {
            task?.cancel()
        }
    }

    // MARK: - Task

    private class Progress: HttpProgress {
        var bytes: Int64?
        var totalBytes: Int64?
        var callback: ((HttpProgressData) -> Void)?
    }

    private class InternalTask {
        var uploadProgress: HttpProgress { upload }
        var downloadProgress: HttpProgress { download }

        let task: URLSessionTask
        var upload: Progress = Progress()
        var download: Progress = Progress()

        var startDate: Date = Date()
        let request: URLRequest
        let queue: DispatchQueue
        let logger: UrlSessionHttpLogger?

        init(task: URLSessionTask, request: URLRequest, queue: DispatchQueue, logger: UrlSessionHttpLogger?) {
            self.task = task
            self.request = request
            self.queue = queue
            self.logger = logger
        }

        func process(response: URLResponse?, error: Error?) {
        }
    }

    private class ResultTask<T>: InternalTask {
        var completion: ((HttpResult<T>) -> Void)?
        var result: T? { nil }
        var error: Error?

        @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
        lazy var continuation: CheckedContinuation<HttpResult<T>, Never>? = nil

        @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
        func await() async -> HttpResult<T> {
            await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation { continuation in
                        self.continuation = continuation
                        resume()
                    }
                },
                onCancel: {
                    cancel()
                }
            )
        }

        override func process(response: URLResponse?, error: Error?) {
            let error = error ?? self.error
            let resultString = log(result: result, response: response)
            logger?.log(response, request, resultString, error as NSError?, startDate: startDate, date: Date())

            let result = Routines.process(response: response, data: result, error: error)
            if #available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *), let continuation = continuation {
                continuation.resume(returning: result)
                self.continuation = nil
            } else {
                queue.async {
                    self.completion?(result)
                }
            }
        }

        func log(result: T?, response: URLResponse?) -> String {
            ""
        }

        func resume() {
            guard task.state == .suspended else { return }

            startDate = Date()
            logger?.log(request, date: startDate)
            task.resume()
        }

        func cancel() {
            task.cancel()
        }
    }

    private class DataTask: ResultTask<Data>, HttpDataTask {
        var data: Data = Data()

        override var result: Data? { data }

        override func log(result: Data?, response: URLResponse?) -> String {
            logger?.log(result, response) ?? ""
        }
    }

    private class DownloadTask: ResultTask<URL>, HttpDownloadTask {
        var url: URL?
        let destination: URL

        override var result: URL? { url }

        override func log(result: URL?, response: URLResponse?) -> String {
            logger?.log(result) ?? ""
        }

        init(task: URLSessionTask, destination: URL, request: URLRequest, queue: DispatchQueue, logger: UrlSessionHttpLogger?) {
            self.destination = destination
            super.init(task: task, request: request, queue: queue, logger: logger)
        }
    }

    // MARK: - Delegate

    private class Delegate: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate {
        var trustPolicies: [String: ServerTrustPolicy]
        let queue: OperationQueue = OperationQueue()
        private let responseQueue: DispatchQueue
        private var tasks: [InternalTask] = []

        init(responseQueue: DispatchQueue, trustPolicies: [String: ServerTrustPolicy]) {
            self.responseQueue = responseQueue
            self.trustPolicies = trustPolicies
            queue.qualityOfService = .userInitiated
            queue.maxConcurrentOperationCount = 1
        }

        func add(task: InternalTask) {
            queue.addOperation {
                self.tasks.append(task)
            }
        }

        // MARK: - Authentication

        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?

            let space = challenge.protectionSpace
            let host = space.host
            let isServerTrust = space.authenticationMethod == NSURLAuthenticationMethodServerTrust
            if isServerTrust, let serverTrust = space.serverTrust, let policy = trustPolicy(host: host) {
                if policy.evaluate(serverTrust: serverTrust, host: host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }

            completionHandler(disposition, credential)
        }

        private func trustPolicy(host: String) -> ServerTrustPolicy? {
            var components = host.components(separatedBy: ".")
            repeat {
                let host = components.isEmpty ? "*" : components.joined(separator: ".")
                if let policy = trustPolicies[host] {
                    return policy
                }
                if components.isEmpty {
                    return nil
                }
                components.remove(at: 0)
            } while true
        }

        // MARK: - Task

        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didSendBodyData bytesSent: Int64,
            totalBytesSent: Int64,
            totalBytesExpectedToSend: Int64
        ) {
            guard let httpTask = tasks.first(where: { $0.task === task }) else { return }

            let total = totalBytesExpectedToSend != NSURLSessionTransferSizeUnknown ? totalBytesExpectedToSend : nil
            httpTask.upload.bytes = totalBytesSent
            httpTask.upload.totalBytes = total
            responseQueue.async {
                httpTask.upload.callback?(HttpProgressData(bytes: totalBytesSent, totalBytes: total))
            }
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            guard let index = tasks.firstIndex(where: { $0.task === task }) else { return }

            let httpTask = tasks.remove(at: index)
            httpTask.process(response: httpTask.task.response, error: httpTask.task.error ?? error)
        }

        // MARK: - Data

        func urlSession(
            _ session: URLSession,
            dataTask: URLSessionDataTask,
            didReceive response: URLResponse,
            completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
        ) {
            guard let httpTask = tasks.first(where: { $0.task === dataTask }) as? DataTask else { return completionHandler(.allow) }

            let total = response.expectedContentLength != NSURLSessionTransferSizeUnknown ? response.expectedContentLength : nil
            httpTask.download.totalBytes = total
            let bytes = httpTask.download.bytes
            responseQueue.async {
                httpTask.download.callback?(HttpProgressData(bytes: bytes, totalBytes: total))
            }
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let httpTask = tasks.first(where: { $0.task === dataTask }) as? DataTask else { return }

            httpTask.data.append(data)
            let bytes = Int64(httpTask.data.count)
            httpTask.download.bytes = bytes
            let total = httpTask.download.totalBytes
            responseQueue.async {
                httpTask.download.callback?(HttpProgressData(bytes: bytes, totalBytes: total))
            }
        }

        // MARK: - Download

        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            guard let httpTask = tasks.first(where: { $0.task === downloadTask }) as? DownloadTask else { return }

            do {
                try? FileManager.default.removeItem(at: httpTask.destination)
                try FileManager.default.moveItem(at: location, to: httpTask.destination)
                httpTask.url = httpTask.destination
            } catch {
                httpTask.error = error
            }
        }

        func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didWriteData bytesWritten: Int64,
            totalBytesWritten: Int64,
            totalBytesExpectedToWrite: Int64
        ) {
            guard let httpTask = tasks.first(where: { $0.task === downloadTask }) as? DownloadTask else { return }

            let total = totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown ? totalBytesExpectedToWrite : nil
            httpTask.download.bytes = totalBytesWritten
            httpTask.download.totalBytes = total
            responseQueue.async {
                httpTask.download.callback?(HttpProgressData(bytes: totalBytesWritten, totalBytes: total))
            }
        }
    }

    // MARK: - Routines

    private enum Routines {
        static func process<DataType>(response: URLResponse?, data: DataType?, error: Error?) -> HttpResult<DataType> {
            var result = HttpResult<DataType>(response: response as? HTTPURLResponse, data: data, error: error.map(Routines.process))
            if let httpResponse = result.response, httpResponse.statusCode >= 400 {
                result.error = .status(code: httpResponse.statusCode, error: error)
            } else if let response = response, result.response == nil {
                result.error = .nonHttpResponse(response: response)
            }
            return result
        }

        static func process(error: Error) -> HttpError {
            let nsError = error as NSError
            guard nsError.domain == NSURLErrorDomain else { return .error(error) }

            switch nsError.code {
                case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost,
                     NSURLErrorDNSLookupFailed, NSURLErrorNotConnectedToInternet:
                    return .unreachable(error)
                default:
                    return .error(error)
            }
        }

        static func moveFile(result: HttpResult<URL>, destination: URL) -> HttpResult<URL> {
            var result = result
            if let url = result.data {
                do {
                    try? FileManager.default.removeItem(at: destination)
                    try FileManager.default.moveItem(at: url, to: destination)
                } catch {
                    result.error = .error(error)
                }
            }
            return result
        }
    }
}
