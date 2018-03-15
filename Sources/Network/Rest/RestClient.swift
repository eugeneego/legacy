//
// LightRestClient
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum RestError: Error {
    case badUrl
    case auth(error: Error?)
    case http(code: Int, error: Error?, body: Data?)
    case error(error: HttpError?, body: Data?)
}

public protocol RestTask {
    func cancel()
}

public protocol RestClient {
    var http: Http { get }
    var baseURL: URL { get }

    @discardableResult
    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask

    @discardableResult
    func create<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask

    @discardableResult
    func create<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask

    @discardableResult
    func read<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask

    @discardableResult
    func update<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask

    @discardableResult
    func update<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask

    @discardableResult
    func delete<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask
}

public extension RestClient {
    @discardableResult
    public func pathWithId(path: String, id: String?) -> String {
        let path = (path.isEmpty || path[path.startIndex] != "/") ? path : String(path[path.index(after: path.startIndex)...])

        if let id = id {
            let delimiter = (!path.isEmpty && path[path.index(before: path.endIndex)] != "/") ? "/" : ""
            return path + delimiter + id
        } else {
            return path
        }
    }

    @discardableResult
    func create<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        path: String, id: String?, object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
        return request(
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
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
        return request(
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
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
        return request(
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
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
        return request(
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
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
        return request(
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
    func delete<ResponseSerializer: HttpSerializer>(
        path: String, id: String?, headers: [String: String],
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
        return request(
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
