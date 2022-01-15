//
// NetworkClient
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum NetworkError: Error {
    case badUrl
    case auth(error: Error?)
    case http(code: Int, result: HttpResult<Data>)
    case error(result: HttpResult<Data>)
}

public protocol NetworkTask: AnyObject {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }

    func cancel()
}

public protocol NetworkClient {
    var http: Http { get }
    var baseURL: URL { get }

    @discardableResult
    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestSerializer.Value?,
        headers: [String: String],
        requestSerializer: RequestSerializer,
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestSerializer.Value?,
        headers: [String: String],
        requestSerializer: RequestSerializer,
        responseSerializer: ResponseSerializer
    ) async -> Result<ResponseSerializer.Value, NetworkError>
}

// Transformers

public protocol LightNetworkClient: NetworkClient {
    @discardableResult
    func request<Request: LightTransformer, Response: LightTransformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func request<Request: LightTransformer, Response: LightTransformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>
}

public protocol FullNetworkClient: NetworkClient {
    @discardableResult
    func request<Request: Transformer, Response: Transformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.Destination, NetworkError>) -> Void
    ) -> NetworkTask where Request.Source == Any, Response.Source == Any

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func request<Request: Transformer, Response: Transformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any
}

// Codable

public protocol CodableNetworkClient: NetworkClient {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }

    @discardableResult
    func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func request<RequestObject: Encodable, ResponseObject: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestObject?,
        headers: [String: String],
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func request<RequestObject: Encodable, ResponseObject: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestObject?,
        headers: [String: String],
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) async -> Result<ResponseObject, NetworkError>
}
