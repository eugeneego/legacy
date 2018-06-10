//
// UrlSessionHttp
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class UrlSessionHttp: Http {
    open let session: URLSession
    open let responseQueue: DispatchQueue

    open let logger: Logger?
    open let loggerTag: String

    open var maxLoggingBodySize: Int = 8192

    open var trustPolicies: [String: ServerTrustPolicy] {
        get {
            return delegateObject.trustPolicies
        }
        set {
            delegateObject.trustPolicies = newValue
        }
    }

    private let delegateObject: Delegate

    public init(
        configuration: URLSessionConfiguration, responseQueue: DispatchQueue,
        logger: Logger? = nil, loggerTag: String = String(describing: UrlSessionHttp.self)
    ) {
        self.logger = logger
        self.loggerTag = loggerTag
        delegateObject = Delegate()
        session = URLSession(configuration: configuration, delegate: delegateObject, delegateQueue: nil)
        self.responseQueue = responseQueue
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Log

    private func nils(_ object: Any?) -> String {
        return object.map { "\($0)" } ?? "nil"
    }

    private func logHeaders(_ httpHeaders: [AnyHashable: Any]?) -> String? {
        let headers = httpHeaders?.map { key, value -> String in "\(key): \(value)" }
        return headers.map { "[\n    " + $0.joined(separator: "\n    ") + "\n  ]" }
    }

    private func log(_ request: URLRequest, date: Date) {
        guard let logger = logger else { return }

        let tag = "←"
        let body = request.httpBody.flatMap { data -> String? in
            if let type = request.allHTTPHeaderFields?["Content-Type"], isText(type: type) && data.count <= maxLoggingBodySize {
                return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
            } else {
                return "\(data.count) bytes"
            }
        }
        let string =
            "\n__\n" +
            "\(tag) Request: \(nils(request.httpMethod)) \(nils(request.url))\n" +
            "\(tag) Headers: \(nils(logHeaders(request.allHTTPHeaderFields)))\n" +
            "\(tag) Body: \(nils(body))\n" +
            "‾‾"
        logger.log(string, level: .info, tag: loggerTag, function: "")
    }

    private func isText(type: String) -> Bool {
        return type.contains("json") || type.contains("xml") || type.contains("text")
    }

    private func log(
        _ response: URLResponse?, _ request: URLRequest,
        _ data: Data?, _ error: NSError?,
        duration: TimeInterval, date: Date
    ) {
        guard let logger = logger else { return }

        let urlResponse = response as? HTTPURLResponse

        let loggingLevel: LoggingLevel = (urlResponse?.statusCode ?? 1000) < 400 ? .info : .error

        let tag = "→"
        let body = data.flatMap { data -> String? in
            if let type = urlResponse?.allHeaderFields["Content-Type"] as? String, isText(type: type) && data.count <= maxLoggingBodySize {
                return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
            } else {
                return "\(data.count) bytes"
            }
        }
        let string =
            "\n__\n" +
            "\(tag) Request: \(nils(request.httpMethod)) \(nils(request.url))\n" +
            "\(tag) Response: \(nils(urlResponse?.statusCode)), Duration: \(String(format: "%0.3f", duration)) s\n" +
            "\(tag) Headers: \(nils(logHeaders(urlResponse?.allHeaderFields)))\n" +
            "\(tag) Data: \(nils(body))\n" +
            "\(tag) Error: \(nils(error))\n" +
            "‾‾"
        logger.log(string, level: loggingLevel, tag: loggerTag, function: "")
    }

    // MARK: - Request

    open func data(request: URLRequest, completion: @escaping HttpCompletion) -> HttpTask {
        let start = Date()
        log(request, date: start)

        let responseQueue = self.responseQueue

        let cmpl: HttpCompletion = { response, data, error in
            responseQueue.async {
                completion(response, data, error)
            }
        }

        let dataTask = session.dataTask(with: request)
        let task = Task(dataTask, startDate: start) { data, response, error in
            let end = Date()
            self.log(response, request, data, error as NSError?, duration: end.timeIntervalSince(start), date: end)

            guard let response = response, let data = data else {
                cmpl(nil, nil, error.map(self.processError))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                cmpl(nil, data, .nonHttpResponse(response: response))
                return
            }

            if httpResponse.statusCode >= 400 {
                cmpl(httpResponse, data, .status(code: httpResponse.statusCode, error: error))
            } else {
                cmpl(httpResponse, data, error.map(self.processError))
            }
        }

        delegateObject.tasks.append(task)

        return task
    }

    open func processError(_ error: Error) -> HttpError {
        let urlError = error as NSError
        guard urlError.domain == NSURLErrorDomain else { return HttpError.error(error) }

        switch urlError.code {
            case NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost,
                    NSURLErrorDNSLookupFailed, NSURLErrorNotConnectedToInternet:
                return HttpError.unreachable(error)
            default:
                return HttpError.error(error)
        }
    }

    // MARK: - Task

    private class Progress: HttpProgress {
        var bytes: Int64?
        var totalBytes: Int64?
        var callback: HttpProgressCallback?

        func setCallback(_ callback: HttpProgressCallback?) {
            self.callback = callback
        }
    }

    private class Task: HttpTask {
        var uploadProgress: HttpProgress { return upload }
        var downloadProgress: HttpProgress { return download }

        let task: URLSessionTask
        let startDate: Date
        let completion: (Data?, URLResponse?, Error?) -> Void
        var data: Data = Data()
        var upload: Progress = Progress()
        var download: Progress = Progress()

        init(_ task: URLSessionTask, startDate: Date, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.task = task
            self.startDate = startDate
            self.completion = completion
        }

        func resume() {
            task.resume()
        }

        func cancel() {
            task.cancel()
        }
    }

    // MARK: - Delegate

    private class Delegate: NSObject, URLSessionDataDelegate {
        var trustPolicies: [String: ServerTrustPolicy] = [:]
        var tasks: [Task] = []

        func urlSession(
            _ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?

            let host = challenge.protectionSpace.host
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust, let policy = trustPolicies[host] {
                if policy.evaluate(serverTrust: serverTrust, host: host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }

            completionHandler(disposition, credential)
        }

        func urlSession(
            _ session: URLSession, task: URLSessionTask,
            didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64
        ) {
            guard let httpTask = tasks.first(where: { $0.task === task }) else { return }

            let total = totalBytesExpectedToSend != NSURLSessionTransferSizeUnknown ? totalBytesExpectedToSend : nil
            httpTask.upload.bytes = totalBytesSent
            httpTask.upload.totalBytes = total
            httpTask.upload.callback?(httpTask.upload.bytes, httpTask.upload.totalBytes)
        }

        func urlSession(
            _ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
            completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
        ) {
            guard let httpTask = tasks.first(where: { $0.task === dataTask }) else { return completionHandler(.cancel) }

            let total = response.expectedContentLength != NSURLSessionTransferSizeUnknown ? response.expectedContentLength : nil
            httpTask.download.totalBytes = total
            httpTask.download.callback?(httpTask.download.bytes, httpTask.download.totalBytes)
            completionHandler(.allow)
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let httpTask = tasks.first(where: { $0.task === dataTask }) else { return }

            httpTask.data.append(data)
            httpTask.download.bytes = Int64(httpTask.data.count)
            httpTask.download.callback?(httpTask.download.bytes, httpTask.download.totalBytes)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            guard let index = tasks.index(where: { $0.task === task }) else { return }

            let httpTask = tasks.remove(at: index)
            httpTask.completion(httpTask.data, httpTask.task.response, httpTask.task.error ?? error)
        }
    }
}
