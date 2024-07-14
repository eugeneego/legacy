//
// UrlSessionHttp
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class UrlSessionHttp: Http, @unchecked Sendable {
    public let session: URLSession
    private let delegateObject: Delegate
    private let logger: UrlSessionHttpLogger?

    public init(
        configuration: URLSessionConfiguration,
        trustPolicies: [String: ServerTrustPolicy] = [:],
        logger: UrlSessionHttpLogger? = nil
    ) {
        self.logger = logger
        delegateObject = Delegate(trustPolicies: trustPolicies)
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: delegateObject.queue)
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Request

    open func data(request: URLRequest) -> HttpDataTask {
        let dataTask = session.dataTask(with: request)
        let task = DataTask(task: dataTask, request: request, logger: logger)
        delegateObject.add(task: task)
        return task
    }

    open func download(request: URLRequest, destination: URL) -> HttpDownloadTask {
        let downloadTask = session.downloadTask(with: request)
        let task = DownloadTask(task: downloadTask, destination: destination, request: request, logger: logger)
        delegateObject.add(task: task)
        return task
    }

    open func data(request: URLRequest) async -> HttpResult<Data> {
        let startDate = Date()
        logger?.log(request, date: startDate)
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            do {
                let data = try await session.data(for: request)
                logger?.log(data.1, request, logger?.log(data.0, data.1) ?? "", nil, startDate: startDate, date: Date())
                return Routines.process(response: data.1, data: data.0, error: nil)
            } catch {
                logger?.log(nil, request, "", error as NSError?, startDate: startDate, date: Date())
                return Routines.process(response: nil, data: nil, error: error)
            }
        } else {
            let task = TaskActor()
            return await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation { continuation in
                        Task {
                            await task.resume(task: session.dataTask(with: request) { [logger] data, response, error in
                                let content = logger?.log(data, response) ?? ""
                                logger?.log(response, request, content, error as NSError?, startDate: startDate, date: Date())
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

    open func download(request: URLRequest, destination: URL) async -> HttpResult<URL> {
        let startDate = Date()
        logger?.log(request, date: startDate)
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *) {
            do {
                let data = try await session.download(for: request)
                logger?.log(data.1, request, logger?.log(data.0) ?? "", nil, startDate: startDate, date: Date())
                var result = Routines.process(response: data.1, data: data.0, error: nil)
                result = Routines.moveFile(result: result, destination: destination)
                return Routines.process(response: data.1, data: data.0, error: nil)
            } catch {
                logger?.log(nil, request, "", error as NSError?, startDate: startDate, date: Date())
                return Routines.process(response: nil, data: nil, error: error)
            }
        } else {
            let task = TaskActor()
            return await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation { continuation in
                        Task {
                            await task.resume(task: session.downloadTask(with: request) { [logger] url, response, error in
                                let content = logger?.log(url) ?? ""
                                logger?.log(response, request, content, error as NSError?, startDate: startDate, date: Date())
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

    private final class TaskProgress: HttpProgress, @unchecked Sendable {
        private(set) var data: HttpProgressData = .init(bytes: nil, totalBytes: nil)
        var callback: ((HttpProgressData) -> Void)?

        init() {
        }

        func set(bytes: Int64?, totalBytes: Int64?) {
            data.bytes = bytes
            data.totalBytes = totalBytes
            DispatchQueue.main.async {
                self.callback?(self.data)
            }
        }

        func set(bytes: Int64?) {
            set(bytes: bytes, totalBytes: data.totalBytes)
        }

        func set(totalBytes: Int64?) {
            set(bytes: data.bytes, totalBytes: totalBytes)
        }
    }

    private class InternalTask: @unchecked Sendable {
        var uploadProgress: HttpProgress { upload }
        var downloadProgress: HttpProgress { download }

        let task: URLSessionTask
        let upload: TaskProgress = TaskProgress()
        let download: TaskProgress = TaskProgress()
        var progress: Progress { task.progress }

        var startDate: Date = Date()
        let request: URLRequest
        let logger: UrlSessionHttpLogger?

        init(task: URLSessionTask, request: URLRequest, logger: UrlSessionHttpLogger?) {
            self.task = task
            self.request = request
            self.logger = logger
        }

        func process(response: URLResponse?, error: Error?) {
        }
    }

    private class ResultTask<T: Sendable>: InternalTask, @unchecked Sendable {
        var result: T? { nil }
        var error: Error?
        var continuation: CheckedContinuation<HttpResult<T>, Never>?

        func run() async -> HttpResult<T> {
            await withTaskCancellationHandler(
                operation: {
                    await withCheckedContinuation { continuation in
                        resume(continuation: continuation)
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

            guard let continuation else { return }

            let result = Routines.process(response: response, data: result, error: error)
            continuation.resume(returning: result)
            self.continuation = nil
        }

        func log(result: T?, response: URLResponse?) -> String {
            ""
        }

        private func resume(continuation: CheckedContinuation<HttpResult<T>, Never>) {
            guard task.state == .suspended else {
                return continuation.resume(returning: HttpResult<T>(response: nil, data: nil, error: .invalidState))
            }

            self.continuation = continuation
            startDate = Date()
            logger?.log(request, date: startDate)
            task.resume()
        }

        private func cancel() {
            task.cancel()
        }
    }

    private class DataTask: ResultTask<Data>, HttpDataTask, @unchecked Sendable {
        var data: Data = Data()

        override var result: Data? { data }

        override func log(result: Data?, response: URLResponse?) -> String {
            logger?.log(result, response) ?? ""
        }
    }

    private class DownloadTask: ResultTask<URL>, HttpDownloadTask, @unchecked Sendable {
        var url: URL?
        let destination: URL

        override var result: URL? { url }

        override func log(result: URL?, response: URLResponse?) -> String {
            logger?.log(result) ?? ""
        }

        init(task: URLSessionTask, destination: URL, request: URLRequest, logger: UrlSessionHttpLogger?) {
            self.destination = destination
            super.init(task: task, request: request, logger: logger)
        }
    }

    // MARK: - Delegate

    private final class Delegate: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate, @unchecked Sendable {
        let trustPolicies: [String: ServerTrustPolicy]
        let queue: OperationQueue = OperationQueue()
        private var tasks: [InternalTask] = []

        init(trustPolicies: [String: ServerTrustPolicy]) {
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
            didReceive challenge: URLAuthenticationChallenge
        ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
            let space = challenge.protectionSpace
            let host = space.host
            let isServerTrust = space.authenticationMethod == NSURLAuthenticationMethodServerTrust
            if isServerTrust, let serverTrust = space.serverTrust, let policy = trustPolicy(host: host) {
                if await policy.evaluate(serverTrust: serverTrust, host: host) {
                    return (.useCredential, URLCredential(trust: serverTrust))
                } else {
                    return (.cancelAuthenticationChallenge, nil)
                }
            } else {
                return (.performDefaultHandling, nil)
            }
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
            httpTask.upload.set(bytes: totalBytesSent, totalBytes: total)
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
            httpTask.download.set(totalBytes: total)
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let httpTask = tasks.first(where: { $0.task === dataTask }) as? DataTask else { return }

            httpTask.data.append(data)
            httpTask.download.set(bytes: Int64(httpTask.data.count))
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
            httpTask.download.set(bytes: totalBytesWritten, totalBytes: total)
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
            case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
                return .unreachable(error)
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorDNSLookupFailed:
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
