//
// FullRestClient
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol FullRestClient: RestClient, FullNetworkClient {
    @discardableResult
    func create<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any

    @discardableResult
    func create<ResponseTransformer: Transformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any

    @discardableResult
    func read<ResponseTransformer: Transformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any

    @discardableResult
    func update<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any

    @discardableResult
    func update<ResponseTransformer: Transformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any

    @discardableResult
    func partialUpdate<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any

    @discardableResult
    func delete<ResponseTransformer: Transformer>(
        path: String, id: String?, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any
}

public extension FullRestClient {
    @discardableResult
    public func create<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
        return request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    @discardableResult
    public func create<ResponseTransformer: Transformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any {
        return request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    public func read<ResponseTransformer: Transformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any {
        return request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer<Any>(),
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    @discardableResult
    public func update<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
        return request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    @discardableResult
    public func update<ResponseTransformer: Transformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any {
        return request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    public func partialUpdate<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
        return request(
            method: .patch,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    @discardableResult
    public func delete<ResponseTransformer: Transformer>(
        path: String, id: String?, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where ResponseTransformer.Source == Any {
        return request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer<Any>(),
            responseTransformer: responseTransformer,
            completion: completion
        )
    }
}
