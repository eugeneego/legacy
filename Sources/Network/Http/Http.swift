//
// Http
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public typealias HttpCompletion = (HTTPURLResponse?, Data?, HttpError?) -> Void

public protocol HttpTask {
    func resume()
    func cancel()
}

public protocol Http {
    @discardableResult
    func data(request: URLRequest, completion: @escaping HttpCompletion) -> HttpTask

    func urlWithParameters(url: URL, parameters: [String: String]) -> URL
    func request(method: String, url: URL, urlParameters: [String: String], headers: [String: String], body: Data?) -> URLRequest
}

public enum HttpError: Error {
    case nonHttpResponse(response: URLResponse)
    case badUrl
    case parsingFailed
    case unreachable(Error)
    case error(Error)
    case status(code: Int, error: Error?)
}

public enum HttpMethod {
    case get
    case head
    case post
    case put
    case patch
    case delete
    case trace
    case options
    case connect
    case custom(String)

    public var value: String {
        switch self {
            case .get: return "GET"
            case .head: return "HEAD"
            case .post: return "POST"
            case .put: return "PUT"
            case .patch: return "PATCH"
            case .delete: return "DELETE"
            case .trace: return "TRACE"
            case .options: return "OPTIONS"
            case .connect: return "CONNECT"
            case .custom(let value): return value
        }
    }
}

public extension Http {
    @discardableResult
    public func data(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String], body: Data?, completion: @escaping HttpCompletion
    ) -> HttpTask {
        let req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return data(request: req, completion: completion)
    }

    @discardableResult
    public func data<T: HttpSerializer>(
        request: URLRequest, serializer: T,
        completion: @escaping (HTTPURLResponse?, T.Value?, Data?, HttpError?) -> Void
    ) -> HttpTask {
        return data(request: request) { response, data, error in
            let object = error == nil ? serializer.deserialize(data) : nil
            var error = error
            if error == nil && object == nil {
                error = HttpError.parsingFailed
            }
            completion(response, object, data, error)
        }
    }

    public func urlWithParameters(url: URL, parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return url }

        if !parameters.isEmpty {
            let serializer = UrlEncodedHttpSerializer()
            var params = serializer.deserialize(components.query) ?? [:]
            parameters.forEach { key, value in
                params[key] = value
            }
            components.percentEncodedQuery = serializer.serialize(params)
        }

        return components.url ?? url
    }

    public func request(
        method: String, url: URL, urlParameters: [String: String],
        headers: [String: String], body: Data?
    ) -> URLRequest {
        var request = URLRequest(url: urlWithParameters(url: url, parameters: urlParameters))
        request.httpMethod = method
        request.httpBody = body
        headers.forEach { name, value in
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }

    public func request(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String], body: Data?
    ) -> URLRequest {
        return request(method: method.value, url: url, urlParameters: urlParameters, headers: headers, body: body)
    }

    public func request<T: HttpSerializer>(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String],
        object: T.Value?, serializer: T
    ) -> URLRequest {
        var req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: serializer.serialize(object))
        req.setValue(serializer.contentType, forHTTPHeaderField: "Content-Type")
        return req
    }
}
