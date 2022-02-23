//
// CodableRestClient
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol CodableRestClient: RestClient, CodableNetworkClient {
    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response>

    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) -> NetworkTask<Response>

    func read<Response: Decodable>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String]
    ) -> NetworkTask<Response>

    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response>

    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) -> NetworkTask<Response>

    func partialUpdate<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response>

    func delete<Response: Decodable>(path: String, id: String?, headers: [String: String]) -> NetworkTask<Response>

    // MARK: - Async

    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    func read<Response: Decodable>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    func partialUpdate<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError>

    func delete<Response: Decodable>(path: String, id: String?, headers: [String: String]) async -> Result<Response, NetworkError>
}

public extension CodableRestClient {
    func create<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response> {
        request(method: .post, path: pathWithId(path: path, id: id), parameters: [:], object: object, headers: headers)
    }

    func create<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) -> NetworkTask<Response> {
        request(
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
    ) -> NetworkTask<Response> {
        request(method: .get, path: pathWithId(path: path, id: id), parameters: parameters, object: Nil?.none, headers: headers)
    }

    func update<Request: Encodable, Response: Decodable>(
        path: String,
        id: String?,
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response> {
        request(method: .put, path: pathWithId(path: path, id: id), parameters: [:], object: object, headers: headers)
    }

    func update<Response: Decodable>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String]
    ) -> NetworkTask<Response> {
        request(
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
    ) -> NetworkTask<Response> {
        request(method: .patch, path: pathWithId(path: path, id: id), parameters: [:], object: object, headers: headers)
    }

    func delete<Response: Decodable>(path: String, id: String?, headers: [String: String]) -> NetworkTask<Response> {
        request(method: .delete, path: pathWithId(path: path, id: id), parameters: [:], object: Nil?.none, headers: headers)
    }
}

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
