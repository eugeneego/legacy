//
// LightRestClient
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol RestClient: NetworkClient {
    @discardableResult
    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func read<Response: HttpSerializer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func partialUpdate<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func delete<Response: HttpSerializer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
    ) -> NetworkTask

    // MARK: - Async

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func create<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func read<Response: HttpSerializer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func update<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func update<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func partialUpdate<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func delete<Response: HttpSerializer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>
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
    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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
    func create<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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
    func read<Response: HttpSerializer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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
    func update<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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
    func update<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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
    func partialUpdate<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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
    func delete<Response: HttpSerializer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseSerializer: Response,
        completion: @escaping (Result<Response.Value, NetworkError>) -> Void
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

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension RestClient {
    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestSerializer: requestSerializer,
            responseSerializer: responseSerializer
        )
    }

    func create<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: VoidHttpSerializer(),
            responseSerializer: responseSerializer
        )
    }

    func read<Response: HttpSerializer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestSerializer: VoidHttpSerializer(),
            responseSerializer: responseSerializer
        )
    }

    func update<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestSerializer: requestSerializer,
            responseSerializer: responseSerializer
        )
    }

    func update<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: responseSerializer
        )
    }

    func partialUpdate<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .patch,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestSerializer: requestSerializer,
            responseSerializer: responseSerializer
        )
    }

    func delete<Response: HttpSerializer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError> {
        await request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestSerializer: VoidHttpSerializer(),
            responseSerializer: responseSerializer
        )
    }
}
