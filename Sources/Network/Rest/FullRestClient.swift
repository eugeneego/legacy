//
// FullRestClient
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public protocol FullRestClient: RestClient {
    @discardableResult
    func request<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any

    @discardableResult
    func create<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any

    @discardableResult
    func create<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any

    @discardableResult
    func read<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any

    @discardableResult
    func update<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any

    @discardableResult
    func update<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any

    @discardableResult
    func delete<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any
}

public extension FullRestClient {
    @discardableResult
    func request<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
        let requestSerializer = JsonModelBackwardTransformerHttpSerializer(transformer: requestTransformer)
        let responseSerializer = JsonModelForwardTransformerHttpSerializer(transformer: responseTransformer)

        return request(
            method: method,
            path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func create<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
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
    func create<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any {
        return request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelForwardTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    func read<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any {
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
    func update<RequestTransformer: BackwardTransformer, ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
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
    func update<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any {
        return request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelForwardTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    func delete<ResponseTransformer: ForwardTransformer>(
        path: String, id: String?, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, RestError>) -> Void
    ) -> RestTask where ResponseTransformer.Source == Any {
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
