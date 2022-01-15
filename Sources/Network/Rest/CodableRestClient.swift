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
    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func read<Response: Decodable>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func partialUpdate<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func delete<Response: Decodable>(
        path: String,
        id: String?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask

    // MARK: - Async

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func read<Response: Decodable>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func partialUpdate<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func delete<Response: Decodable>(path: String, id: String?, headers: [String: String]) async -> Result<Response, NetworkError>
}

public extension CodableRestClient {
    @discardableResult
    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
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
    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder),
            completion: completion
        )
    }

    @discardableResult
    func read<Response: Decodable>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
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
    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
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
    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder),
            completion: completion
        )
    }

    @discardableResult
    func partialUpdate<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
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
    func delete<Response: Decodable>(
        path: String,
        id: String?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
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

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension CodableRestClient {
    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(method: .post, path: pathWithId(path: path, id: id), parameters: [:], object: object, headers: headers)
    }

    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder)
        )
    }

    func read<Response: Decodable>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(method: .get, path: pathWithId(path: path, id: id), parameters: parameters, object: Nil?.none, headers: headers)
    }

    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(method: .put, path: pathWithId(path: path, id: id), parameters: [:], object: object, headers: headers)
    }

    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder)
        )
    }

    func partialUpdate<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(method: .patch, path: pathWithId(path: path, id: id), parameters: [:], object: object, headers: headers)
    }

    func delete<Response: Decodable>(path: String, id: String?, headers: [String: String]) async -> Result<Response, NetworkError> {
        await request(method: .delete, path: pathWithId(path: path, id: id), parameters: [:], object: Nil?.none, headers: headers)
    }
}
