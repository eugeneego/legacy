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
    open var logging: Bool = false
    open var logOnlyErrors: Bool = false

    open var trustPolicies: [String: ServerTrustPolicy] {
        get {
            return delegate.trustPolicies
        }
        set {
            delegate.trustPolicies = newValue
        }
    }

    private let delegate: Delegate

    public init(configuration: URLSessionConfiguration, responseQueue: DispatchQueue) {
        delegate = Delegate()
        session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        self.responseQueue = responseQueue
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Log

    private func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        items.forEach { print($0, separator: "", terminator: separator) }
        print("", separator: "", terminator: terminator)
    }

    private let logDateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SSS ZZZZZ")

    private func log(_ request: URLRequest, date: Date) {
        if !logging || logOnlyErrors { return }

        let t = "←"
        let s = request.httpBody.flatMap { String(data: $0, encoding: String.Encoding.utf8) }
        let ns = { (object: Any?) -> String in object.flatMap { "\($0)" } ?? "nil" }
        log(
            "__ \(logDateFormatter.string(from: date))",
            "\(t) Request: \(ns(request.httpMethod)) \(ns(request.url))",
            "\(t) Headers: \(ns(request.allHTTPHeaderFields))",
            "\(t) Body: \(ns(s))",
            "‾‾",
            separator: "\n", terminator: ""
        )
    }

    private func isText(type: String) -> Bool {
        return type.contains("json") || type.contains("xml") || type.contains("text")
    }

    private func log(
        _ response: URLResponse?, _ request: URLRequest,
        _ data: Data?, _ error: NSError?,
        time: TimeInterval, date: Date
    ) {
        if !logging { return }

        let urlResponse = response as? HTTPURLResponse

        if logOnlyErrors && (error == nil && (urlResponse?.statusCode ?? 1000) < 400) {
            return
        }

        let t = "→"
        let s = data.flatMap { d -> String? in
            if let type = urlResponse?.allHeaderFields["Content-Type"] as? String, isText(type: type) {
                return String(data: d, encoding: String.Encoding.utf8)
            } else {
                return "\(d.count) bytes"
            }
        }
        let ns = { (object: Any?) -> String in object.flatMap { "\($0)" } ?? "nil" }
        log(
            "__ \(logDateFormatter.string(from: date))",
            "\(t) Request: \(ns(request.httpMethod)) \(ns(request.url))",
            "\(t) Response: \(ns(urlResponse?.statusCode)), Time: \(String(format: "%0.3f", time)) s",
            "\(t) Headers: \(ns(urlResponse?.allHeaderFields))",
            "\(t) Data: \(ns(s))",
            "\(t) Error: \(ns(error))",
            "‾‾",
            separator: "\n", terminator: ""
        )
    }

    // MARK: - Request

    open func data(request: URLRequest, completion: @escaping HttpCompletion) {
        let start = Date()
        log(request, date: start)

        let responseQueue = self.responseQueue

        let cmpl: HttpCompletion = { response, data, error in
            responseQueue.async {
                completion(response, data, error)
            }
        }

        let task = session.dataTask(with: request) { data, response, error in
            let end = Date()
            self.log(response, request, data, error as NSError?, time: end.timeIntervalSince(start), date: end)

            guard let response = response, let data = data else {
                cmpl(nil, nil, .error(error: error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                cmpl(nil, data, .nonHttpResponse(response: response))
                return
            }

            cmpl(httpResponse, data, error.flatMap { .error(error: $0) })
        }
        task.resume()
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
