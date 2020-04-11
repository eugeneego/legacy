//
// Http
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public typealias HttpCompletion = (HTTPURLResponse?, Data?, HttpError?) -> Void
public typealias HttpProgressCallback = (_ bytes: Int64?, _ totalBytes: Int64?) -> Void

public protocol HttpProgress {
    var bytes: Int64? { get }
    var totalBytes: Int64? { get }
    func setCallback(_ callback: HttpProgressCallback?)
}

public protocol HttpTask {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }

    func resume()
    func cancel()
}

public protocol Http {
    @discardableResult
    func data(request: URLRequest, completion: @escaping HttpCompletion) -> HttpTask
}

public enum HttpError: Error {
    case nonHttpResponse(response: URLResponse)
    case badUrl
    case unreachable(Error)
    case error(Error)
    case status(code: Int, error: Error?)
    case serialization(HttpSerializationError)
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
    func data(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String], body: Data?, completion: @escaping HttpCompletion
    ) -> HttpTask {
        let req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body, bodyStream: nil)
        return data(request: req, completion: completion)
    }

    @discardableResult
    func data(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String], bodyStream: InputStream?, completion: @escaping HttpCompletion
    ) -> HttpTask {
        let req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: nil, bodyStream: bodyStream)
        return data(request: req, completion: completion)
    }

    @discardableResult
    func data<T: HttpSerializer>(
        request: URLRequest, serializer: T,
        completion: @escaping (HTTPURLResponse?, T.Value?, Data?, HttpError?) -> Void
    ) -> HttpTask {
        data(request: request) { response, data, error in
            if let error = error {
                completion(response, nil, data, error)
            } else {
                let result = serializer.deserialize(data)
                switch result {
                    case .success(let value):
                        completion(response, value, data, error)
                    case .failure(let error):
                        completion(response, nil, data, .serialization(error))
                }
            }
        }
    }

    func urlWithParameters(url: URL, parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return url }

        if !parameters.isEmpty {
            let serializer = UrlEncodedHttpSerializer()
            var params = serializer.deserialize(components.query ?? "")
            parameters.forEach { key, value in
                params[key] = value
            }
            components.percentEncodedQuery = serializer.serialize(params)
        }

        return components.url ?? url
    }

    func request(
        method: String, url: URL, urlParameters: [String: String],
        headers: [String: String], body: Data?, bodyStream: InputStream?
    ) -> URLRequest {
        var request = URLRequest(url: urlWithParameters(url: url, parameters: urlParameters))
        request.httpMethod = method
        if let bodyStream = bodyStream {
            request.httpBodyStream = bodyStream
        } else {
            request.httpBody = body
        }
        headers.forEach { name, value in
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }

    func request(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String], body: Data?, bodyStream: InputStream?
    ) -> URLRequest {
        request(method: method.value, url: url, urlParameters: urlParameters, headers: headers, body: body, bodyStream: bodyStream)
    }

    func request<T: HttpSerializer>(
        method: HttpMethod, url: URL, urlParameters: [String: String],
        headers: [String: String],
        object: T.Value?, serializer: T
    ) -> Result<URLRequest, HttpError> {
        let body = serializer.serialize(object)
        return body.map(
            success: { body in
                let data = !body.isEmpty ? body : nil
                var req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: data, bodyStream: nil)
                req.setValue(serializer.contentType, forHTTPHeaderField: "Content-Type")
                return .success(req)
            },
            failure: { .failure(.serialization($0)) }
        )
    }
}
