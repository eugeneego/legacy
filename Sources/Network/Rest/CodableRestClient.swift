//
// CodableRestClient
// Legacy
//
// Created by Eugene Egorov on 08 April 2018.
//

import Foundation

public protocol CodableRestClient: RestClient {
    var decoder: JSONDecoder { get }
    var encoder: JSONEncoder { get }

    @discardableResult
    func request<RequestObject: Codable, ResponseObject: Codable>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<RequestObject: Codable, ResponseObject: Codable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<ResponseObject: Codable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func read<ResponseObject: Codable>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<RequestObject: Codable, ResponseObject: Codable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<ResponseObject: Codable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func delete<ResponseObject: Codable>(
        path: String, id: String?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask
}

public extension CodableRestClient {
    @discardableResult
    public func create<RequestObject: Codable, ResponseObject: Codable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        return request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    public func create<ResponseObject: Codable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        return request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelCodableHttpSerializer<ResponseObject>(),
            completion: completion
        )
    }

    @discardableResult
    public func read<ResponseObject: Codable>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        return request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil as NilCodableModel?,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    public func update<RequestObject: Codable, ResponseObject: Codable>(
        path: String, id: String?, object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        return request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            completion: completion
        )
    }

    @discardableResult
    public func update<ResponseObject: Codable>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        return request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelCodableHttpSerializer<ResponseObject>(decoder: decoder, encoder: encoder),
            completion: completion
        )
    }

    @discardableResult
    func delete<ResponseObject: Codable>(
        path: String, id: String?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        return request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil as NilCodableModel?,
            headers: headers,
            completion: completion
        )
    }
}
