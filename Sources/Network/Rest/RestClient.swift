//
// LightRestClient
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol RestClient: NetworkClient {
    @discardableResult
    func create<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func read<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func partialUpdate<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func delete<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask
}

public extension RestClient {
    @discardableResult
    func pathWithId(path: String, id: String?) -> String {
        let path = path.first == "/" ? String(path.dropFirst()) : path
        if let id = id {
            let delimiter = (!path.isEmpty && path.last != "/") ? "/" : ""
            return path + delimiter + id
        } else {
            return path
        }
    }

    @discardableResult
    func create<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestSerializer: requestSerializer,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func create<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: VoidHttpSerializer(),
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func read<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestSerializer: VoidHttpSerializer(),
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func update<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestSerializer: requestSerializer,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func update<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func partialUpdate<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .patch,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestSerializer: requestSerializer,
            responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    func delete<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestSerializer: VoidHttpSerializer(),
            responseSerializer: responseSerializer,
            completion: completion
        )
    }
}
