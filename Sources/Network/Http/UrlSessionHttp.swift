//
// UrlSessionHttp
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
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

    private func logHeaders(_ httpHeaders: [AnyHashable: Any]?) -> String? {
        let headers = httpHeaders?.map { key, value -> String in
            let key = (key as? String) ?? "\(key)"
            let value = (value as? String) ?? "\(value)"
            return "\(key): \(value)"
        }
        return headers.map { "[\n    " + $0.joined(separator: "\n    ") + "\n  ]" }
    }

    private func log(_ request: URLRequest, date: Date) {
        guard let logger = logger else { return }

        let t = "←"
        let s = request.httpBody.flatMap { data -> String? in
            if let type = request.allHTTPHeaderFields?["Content-Type"], isText(type: type) && data.count <= maxLoggingBodySize {
                return String(data: data, encoding: String.Encoding.utf8)
            } else {
                return "\(data.count) bytes"
            }
        }
        let ns = { (object: Any?) -> String in object.flatMap { "\($0)" } ?? "nil" }
        let string =
            "__" +
            "\(t) Request: \(ns(request.httpMethod)) \(ns(request.url))" +
            "\(t) Headers: \(ns(logHeaders(request.allHTTPHeaderFields)))" +
            "\(t) Body: \(ns(s))" +
            "‾‾"
        logger.log(string, level: .info, for: loggerTag, function: "")
    }

    private func isText(type: String) -> Bool {
        return type.contains("json") || type.contains("xml") || type.contains("text")
    }

    private func log(
        _ response: URLResponse?, _ request: URLRequest,
        _ data: Data?, _ error: NSError?,
        time: TimeInterval, date: Date
    ) {
        guard let logger = logger else { return }

        let urlResponse = response as? HTTPURLResponse

        let loggingLevel: LoggingLevel = (urlResponse?.statusCode ?? 1000) < 400 ? .info : .error

        let t = "→"
        let s = data.flatMap { data -> String? in
            if let type = urlResponse?.allHeaderFields["Content-Type"] as? String, isText(type: type) && data.count <= maxLoggingBodySize {
                return String(data: data, encoding: String.Encoding.utf8)
            } else {
                return "\(data.count) bytes"
            }
        }
        let ns = { (object: Any?) -> String in object.flatMap { "\($0)" } ?? "nil" }
        let string =
            "__" +
            "\(t) Request: \(ns(request.httpMethod)) \(ns(request.url))" +
            "\(t) Response: \(ns(urlResponse?.statusCode)), Time: \(String(format: "%0.3f", time)) s" +
            "\(t) Headers: \(ns(logHeaders(urlResponse?.allHeaderFields)))" +
            "\(t) Data: \(ns(s))" +
            "\(t) Error: \(ns(error))" +
            "‾‾"
        logger.log(string, level: loggingLevel, for: loggerTag, function: "")
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

        let dataTask = session.dataTask(with: request) { data, response, error in
            let end = Date()
            self.log(response, request, data, error as NSError?, time: end.timeIntervalSince(start), date: end)

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

        return Task(dataTask)
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

    private class Task: HttpTask {
        let task: URLSessionTask

        init(_ task: URLSessionTask) {
            self.task = task
        }

        func resume() {
            task.resume()
        }

        func cancel() {
            task.cancel()
        }
    }

    // MARK: - Delegate

    private class Delegate: NSObject, URLSessionDelegate {
        var trustPolicies: [String: ServerTrustPolicy] = [:]

        func urlSession(
            _ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            var disposition: Foundation.URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust, let policy = trustPolicies[challenge.protectionSpace.host] {
                if policy.evaluate(serverTrust: serverTrust, host: challenge.protectionSpace.host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }

            completionHandler(disposition, credential)
        }
    }
}
