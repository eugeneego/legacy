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

public class NetworkTask<Value> {
    public var uploadProgress: HttpProgress { fatalError("Should be overridden") }
    public var downloadProgress: HttpProgress { fatalError("Should be overridden") }

    public func run() async -> Result<Value, NetworkError> { fatalError("Should be overridden") }

    public init() {}
}

public protocol NetworkClient {
    var http: Http { get }
    var baseUrl: URL { get }

    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestSerializer.Value?,
        headers: [String: String],
        requestSerializer: RequestSerializer,
        responseSerializer: ResponseSerializer
    ) -> NetworkTask<ResponseSerializer.Value>

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
    func request<Request: LightTransformer, Response: LightTransformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

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
    func request<Request: Transformer, Response: Transformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any

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

    func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response>

    func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String],
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) -> NetworkTask<Response>

    func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

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
