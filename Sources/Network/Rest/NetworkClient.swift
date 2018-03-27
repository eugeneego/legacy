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

public extension NetworkClient {
    @discardableResult
    public func request<RequestTransformer: LightTransformer, ResponseTransformer: LightTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.T, NetworkError>) -> Void
    ) -> NetworkTask {
        let requestSerializer = JsonModelLightTransformerHttpSerializer(transformer: requestTransformer)
        let responseSerializer = JsonModelLightTransformerHttpSerializer(transformer: responseTransformer)

        return request(
            method: method,
            path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func request<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
        let requestSerializer = JsonModelBackwardTransformerHttpSerializer(transformer: requestTransformer)
        let responseSerializer = JsonModelForwardTransformerHttpSerializer(transformer: responseTransformer)

        return request(
            method: method,
            path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }
}
