//
// UrlSessionHttp
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public class UrlSessionHttp: Http {
    public let session: NSURLSession
    public let responseQueue: dispatch_queue_t
    public var logging: Bool = false
    public var logOnlyErrors: Bool = false

    public var trustPolicies: [String: ServerTrustPolicy] {
        get {
            return delegate.trustPolicies
        }
        set {
            delegate.trustPolicies = newValue
        }
    }

    private let delegate: Delegate

    public init(configuration: NSURLSessionConfiguration, responseQueue: dispatch_queue_t) {
        delegate = Delegate()
        session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        self.responseQueue = responseQueue

        logDateFormatter = NSDateFormatter()
        logDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS ZZZZZ"
    }

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Log

    private func log(items: Any..., separator: String = " ", terminator: String = "\n") {
        items.forEach { print($0, separator: "", terminator: separator) }
        print("", separator: "", terminator: terminator)
    }

    private let logDateFormatter: NSDateFormatter

    private func logFormatDate(date: NSDate) -> String {
        return logDateFormatter.stringFromDate(date)
    }

    private func log(request: NSURLRequest, date: NSDate) {
        if !logging || logOnlyErrors { return }

        let t = "←"
        let s = request.HTTPBody.flatMap { String(data: $0, encoding: NSUTF8StringEncoding) }
        let ns = { (object: Any?) -> String in object.flatMap { "\($0)" } ?? "nil" }
        log(
            "__ \(logFormatDate(date))",
            "\(t) Request: \(ns(request.HTTPMethod)) \(ns(request.URL))",
            "\(t) Headers: \(ns(request.allHTTPHeaderFields))",
            "\(t) Body: \(ns(s))",
            "‾‾",
            separator: "\n", terminator: ""
        )
    }

    private func log(
        response: NSURLResponse?, _ request: NSURLRequest,
        _ data: NSData?, _ error: NSError?,
        time: NSTimeInterval, date: NSDate
    ) {
        if !logging { return }

        let urlResponse = response as? NSHTTPURLResponse

        if logOnlyErrors && (error == nil && urlResponse?.statusCode < 400) {
            return
        }

        let t = "→"
        let s = data.flatMap { d -> String? in
            if let type = urlResponse?.allHeaderFields["Content-Type"] as? String
                where type.containsString("json") || type.containsString("xml") || type.containsString("text") {
                return String(data: d, encoding: NSUTF8StringEncoding)
            } else {
                return "\(d.length) bytes"
            }
        }
        let ns = { (object: Any?) -> String in object.flatMap { "\($0)" } ?? "nil" }
        log(
            "__ \(logFormatDate(date))",
            "\(t) Request: \(ns(request.HTTPMethod)) \(ns(request.URL))",
            "\(t) Response: \(ns(urlResponse?.statusCode)), Time: \(String(format: "%0.3f", time)) s",
            "\(t) Headers: \(ns(urlResponse?.allHeaderFields))",
            "\(t) Data: \(ns(s))",
            "\(t) Error: \(ns(error))",
            "‾‾",
            separator: "\n", terminator: ""
        )
    }

    // MARK: - Request

    public func data(request request: NSURLRequest, completion: HttpCompletion) {
        let start = NSDate()
        log(request, date: start)

        let responseQueue = self.responseQueue

        let cmpl: HttpCompletion = { response, data, error in
            dispatch_async(responseQueue) {
                completion(response, data, error)
            }
        }

        let task = session.dataTaskWithRequest(request) { data, response, error in
            let end = NSDate()
            self.log(response, request, data, error, time: end.timeIntervalSinceDate(start), date: end)

            guard let response = response, data = data else {
                cmpl(nil, nil, .Error(error: error))
                return
            }

            guard let httpResponse = response as? NSHTTPURLResponse else {
                cmpl(nil, data, .NonHttpResponse(response: response))
                return
            }

            cmpl(httpResponse, data, error.flatMap { .Error(error: $0) })
        }
        task.resume()
    }

    // MARK: - Delegate

    private class Delegate: NSObject, NSURLSessionDelegate {
        var trustPolicies: [String: ServerTrustPolicy] = [:]

        @objc func URLSession(
            session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge,
            completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void
        ) {
            var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
            var credential: NSURLCredential?

            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                let serverTrust = challenge.protectionSpace.serverTrust, policy = trustPolicies[challenge.protectionSpace.host] {
                if policy.evaluate(serverTrust: serverTrust, host: challenge.protectionSpace.host) {
                    disposition = .UseCredential
                    credential = NSURLCredential(trust: serverTrust)
                } else {
                    disposition = .CancelAuthenticationChallenge
                }
            }

            completionHandler(disposition, credential)
        }
    }
}
