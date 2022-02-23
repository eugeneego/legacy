//
// Http
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol Http {
    func data(request: URLRequest) -> HttpDataTask
    func download(request: URLRequest, destination: URL) -> HttpDownloadTask

    func data(request: URLRequest) async -> HttpResult<Data>
    func download(request: URLRequest, destination: URL) async -> HttpResult<URL>
}

public protocol HttpTask: AnyObject {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }
}

public protocol HttpDataTask: HttpTask {
    func run() async -> HttpResult<Data>
}

public protocol HttpDownloadTask: HttpTask {
    func run() async -> HttpResult<URL>
}

public struct HttpProgressData {
    public var bytes: Int64?
    public var totalBytes: Int64?

    public init(bytes: Int64?, totalBytes: Int64?) {
        self.bytes = bytes
        self.totalBytes = totalBytes
    }
}

public protocol HttpProgress: AnyObject {
    var data: HttpProgressData { get }
    var callback: ((HttpProgressData) -> Void)? { get set }
}

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

public enum HttpError: Error {
    case invalidState
    case nonHttpResponse(response: URLResponse)
    case badUrl
    case unreachable(Error)
    case status(code: Int, error: Error?)
    case serialization(Error)
    case error(Error)
}

public struct HttpRequestParameters {
    var method: HttpMethod
    var url: URL
    var query: [String: String]
    var headers: [String: String] = [:]
    var body: HttpBody?

    public init(method: HttpMethod, url: URL, query: [String: String] = [:], headers: [String: String] = [:], body: HttpBody? = nil) {
        self.method = method
        self.url = url
        self.query = query
        self.headers = headers
        self.body = body
    }
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
    func data(parameters: HttpRequestParameters) -> HttpDataTask {
        data(request: request(parameters: parameters))
    }

    func download(parameters: HttpRequestParameters, destination: URL) -> HttpDownloadTask {
        download(request: request(parameters: parameters), destination: destination)
    }

    func urlWithQuery(url: URL, query: [String: String]) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return url }
        if !query.isEmpty {
            var queryItems = components.queryItems ?? []
            query.forEach { key, value in
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }
        return components.url ?? url
    }

    func request(parameters: HttpRequestParameters) -> URLRequest {
        var request = URLRequest(url: urlWithQuery(url: parameters.url, query: parameters.query))
        request.httpMethod = parameters.method.value
        switch parameters.body {
            case .data(let data):
                request.httpBody = data
            case .stream(let stream):
                request.httpBodyStream = stream
            case nil:
                break
        }
        parameters.headers.forEach { name, value in
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }

    func data(request: URLRequest) async -> HttpResult<Data> {
        let task: HttpDataTask = data(request: request)
        return await task.run()
    }

    func download(request: URLRequest, destination: URL) async -> HttpResult<URL> {
        let task: HttpDownloadTask = download(request: request, destination: destination)
        return await task.run()
    }

    func data(parameters: HttpRequestParameters) async -> HttpResult<Data> {
        await data(request: request(parameters: parameters))
    }

    func download(parameters: HttpRequestParameters, destination: URL) async -> HttpResult<URL> {
        await download(request: request(parameters: parameters), destination: destination)
    }
}
