//
// Http
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct HttpResult<DataType> {
    public var response: HTTPURLResponse?
    public var data: DataType?
    public var error: HttpError?

    public init(response: HTTPURLResponse?, data: DataType?, error: HttpError?) {
        self.response = response
        self.data = data
        self.error = error
    }
}

public struct HttpProgressData {
    public var bytes: Int64?
    public var totalBytes: Int64?

    public init(bytes: Int64?, totalBytes: Int64?) {
        self.bytes = bytes
        self.totalBytes = totalBytes
    }
}

public typealias HttpDataCompletion = (HttpResult<Data>) -> Void
public typealias HttpDownloadCompletion = (HttpResult<URL>) -> Void
public typealias HttpProgressCallback = (HttpProgressData) -> Void

public protocol HttpProgress: AnyObject {
    var bytes: Int64? { get }
    var totalBytes: Int64? { get }
    var callback: HttpProgressCallback? { get set }
}

public protocol HttpTask: AnyObject {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }

    func resume()
    func cancel()
}

public protocol HttpDataTask: HttpTask {
    var completion: HttpDataCompletion? { get set }
}

public protocol HttpDownloadTask: HttpTask {
    var completion: HttpDownloadCompletion? { get set }
}

public protocol Http {
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
        let request = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return data(request: request)
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
        let request = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return download(request: request, destination: destination)
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

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func data(request: URLRequest) async -> HttpResult<Data> {
        await withCheckedContinuation { continuation in
            let task: HttpDataTask = data(request: request)
            task.completion = continuation.resume(returning:)
            task.resume()
        }
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func download(request: URLRequest, destination: URL) async -> HttpResult<URL> {
        await withCheckedContinuation { continuation in
            let task: HttpDownloadTask = download(request: request, destination: destination)
            task.completion = continuation.resume(returning:)
            task.resume()
        }
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func data(
        method: HttpMethod,
        url: URL,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: HttpBody? = nil
    ) async -> HttpResult<Data> {
        let request = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return await data(request: request)
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func download(
        method: HttpMethod,
        url: URL,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: HttpBody? = nil,
        destination: URL
    ) async -> HttpResult<URL> {
        let request = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        return await download(request: request, destination: destination)
    }
}
