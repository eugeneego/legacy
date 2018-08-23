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
    case http(code: Int, error: Error?, response: HTTPURLResponse?, data: Data?)
    case error(error: HttpError?, response: HTTPURLResponse?, data: Data?)
}

public protocol NetworkTask {
    var uploadProgress: HttpProgress { get }
    var downloadProgress: HttpProgress { get }
    func cancel()
}

public protocol NetworkClient {
    var http: Http { get }
    var baseURL: URL { get }

    @discardableResult
    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask
}

// Transformers

public protocol LightNetworkClient: NetworkClient {
    @discardableResult
    func request<RequestTransformer: LightTransformer, ResponseTransformer: LightTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.T, NetworkError>) -> Void
    ) -> NetworkTask
}

public protocol FullNetworkClient: NetworkClient {
    @discardableResult
    func request<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any
}

// Codable

public protocol CodableNetworkClient: NetworkClient {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }

    @discardableResult
    func request<RequestObject: Encodable, ResponseObject: Decodable>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func request<RequestObject: Encodable, ResponseObject: Decodable>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestObject?, headers: [String: String],
        decoder: JSONDecoder, encoder: JSONEncoder,
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask
}
