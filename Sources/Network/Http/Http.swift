//
// Http
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public typealias HttpDataCompletion = (HTTPURLResponse?, Data?, HttpError?) -> Void
public typealias HttpDownloadCompletion = (HTTPURLResponse?, URL?, HttpError?) -> Void
public typealias HttpProgressCallback = (_ bytes: Int64?, _ totalBytes: Int64?) -> Void

public protocol HttpProgress: AnyObject {
    var bytes: Int64? { get }
    var totalBytes: Int64? { get }
    var callback: HttpProgressCallback? { get set }
}

public protocol HttpDataTask: AnyObject {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }
    var completion: HttpDataCompletion? { get set }

    func resume()
    func cancel()
}

public protocol HttpDownloadTask: AnyObject {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }
    var completion: HttpDownloadCompletion? { get set }

    func resume()
    func cancel()
}

public protocol Http: AnyObject {
    @discardableResult
    func data(request: URLRequest) -> HttpDataTask
    @discardableResult
    func download(request: URLRequest, destination: URL) -> HttpDownloadTask
}

public enum HttpError: Error {
    case nonHttpResponse(response: URLResponse)
    case badUrl
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

public enum HttpBody {
    case data(Data)
    case stream(InputStream)
}

public extension Http {
    @discardableResult
    func data(
        method: HttpMethod,
        url: URL,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: HttpBody? = nil
    ) -> HttpDataTask {
        let req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return data(request: req)
    }

    @discardableResult
    func download(
        method: HttpMethod,
        url: URL,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: HttpBody? = nil,
        destination: URL
    ) -> HttpDownloadTask {
        let req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return download(request: req, destination: destination)
    }

    func urlWithParameters(url: URL, parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return url }

        if !parameters.isEmpty {
            var queryItems = components.queryItems ?? []
            parameters.forEach { key, value in
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }

        return components.url ?? url
    }

    func request(
        method: HttpMethod,
        url: URL,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: HttpBody? = nil
    ) -> URLRequest {
        var request = URLRequest(url: urlWithParameters(url: url, parameters: urlParameters))
        request.httpMethod = method.value
        switch body {
            case .data(let data):
                request.httpBody = data
            case .stream(let stream):
                request.httpBodyStream = stream
            case nil:
                break
        }
        headers.forEach { name, value in
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }
}
