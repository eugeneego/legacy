//
// CodableRestClient
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol CodableRestClient: RestClient, CodableNetworkClient {
    @discardableResult
    func create<RequestObject: Encodable, ResponseObject: Decodable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<ResponseObject: Decodable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func read<ResponseObject: Decodable>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<RequestObject: Encodable, ResponseObject: Decodable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<ResponseObject: Decodable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func partialUpdate<RequestObject: Encodable, ResponseObject: Decodable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func delete<ResponseObject: Decodable>(
        path: String, id: String?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask
}

public extension CodableRestClient {
    @discardableResult
    func create<RequestObject: Encodable, ResponseObject: Decodable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    func create<ResponseObject: Decodable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelDecodableHttpSerializer<ResponseObject>(decoder: decoder),
            completion: completion
        )
    }

    @discardableResult
    func read<ResponseObject: Decodable>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: Nil?.none,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    func update<RequestObject: Encodable, ResponseObject: Decodable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    func update<ResponseObject: Decodable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelDecodableHttpSerializer<ResponseObject>(decoder: decoder),
            completion: completion
        )
    }

    @discardableResult
    func partialUpdate<RequestObject: Encodable, ResponseObject: Decodable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .patch,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    func delete<ResponseObject: Decodable>(
        path: String, id: String?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: Nil?.none,
            headers: headers,
            completion: completion
        )
    }
}
