//
// UrlSessionHttpLogger
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol UrlSessionHttpLogger: Sendable {
    func log(_ request: URLRequest, date: Date)

    func log(
        _ response: URLResponse?,
        _ request: URLRequest,
        _ content: String,
        _ error: NSError?,
        startDate: Date,
        date: Date
    )

    func log(_ data: Data?, _ response: URLResponse?) -> String

    func log(_ url: URL?) -> String
}

open class DefaultUrlSessionHttpLogger: UrlSessionHttpLogger, @unchecked Sendable {
    public let logger: Logger
    public let loggerTag: String

    open var maxBodySize: Int = 8192

    public init(logger: Logger, loggerTag: String = String(describing: UrlSessionHttp.self)) {
        self.logger = logger
        self.loggerTag = loggerTag
    }

    open func log(_ request: URLRequest, date: Date) {
        let tag = "←"
        let body = request.httpBody.flatMap { data -> String? in
            if let type = request.allHTTPHeaderFields?["Content-Type"], isText(type: type) && data.count <= maxBodySize {
                return String(decoding: data, as: UTF8.self)
            } else {
                return "\(data.count) bytes"
            }
        } ?? request.httpBodyStream.map { _ in "stream" }
        let string =
            """
            \n__
            \(tag) Request: \(nils(request.httpMethod)) \(nils(request.url))
            \(tag) Headers: \(nils(logHeaders(request.allHTTPHeaderFields)))
            \(tag) Body: \(nils(body))
            ‾‾
            """
        logger.log(string, level: .info, tag: loggerTag, function: "")
    }

    open func log(
        _ response: URLResponse?,
        _ request: URLRequest,
        _ content: String,
        _ error: NSError?,
        startDate: Date,
        date: Date
    ) {
        let duration = date.timeIntervalSince(startDate)
        let urlResponse = response as? HTTPURLResponse
        let loggingLevel: LoggingLevel = (urlResponse?.statusCode ?? 1000) < 400 ? .info : .error
        let tag = "→"
        let string =
            """
            \n__
            \(tag) Request: \(nils(request.httpMethod)) \(nils(request.url))
            \(tag) Response: \(nils(urlResponse?.statusCode)), Duration: \(String(format: "%0.3f", duration)) s
            \(tag) Headers: \(nils(logHeaders(urlResponse?.allHeaderFields)))
            \(tag) \(content)
            \(tag) Error: \(nils(error))
            ‾‾
            """
        logger.log(string, level: loggingLevel, tag: loggerTag, function: "")
    }

    open func log(_ data: Data?, _ response: URLResponse?) -> String {
        let urlResponse = response as? HTTPURLResponse
        let body = data.flatMap { data -> String? in
            if let type = urlResponse?.allHeaderFields["Content-Type"] as? String, isText(type: type) && data.count <= maxBodySize {
                return String(decoding: data, as: UTF8.self)
            } else {
                return "\(data.count) bytes"
            }
        }
        return "Data: \(nils(body))"
    }

    open func log(_ url: URL?) -> String {
        "URL: \(nils(url?.absoluteString))"
    }

    private func nils(_ object: Any?) -> String {
        object.map { "\($0)" } ?? "nil"
    }

    private func logHeaders(_ httpHeaders: [AnyHashable: Any]?) -> String? {
        let headers = httpHeaders?.map { key, value -> String in "\(key): \(value)" }
        return headers.map { "[\n    " + $0.joined(separator: "\n    ") + "\n  ]" }
    }

    private func isText(type: String) -> Bool {
        type.contains("json") || type.contains("xml") || type.contains("text") || type.contains("www-form-urlencoded")
    }
}
