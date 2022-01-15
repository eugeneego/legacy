//
// LightRestClient
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol LightRestClient: RestClient, LightNetworkClient {
    @discardableResult
    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func create<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func read<Response: LightTransformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func update<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func partialUpdate<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    @discardableResult
    func delete<Response: LightTransformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask

    // MARK: - Async

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func create<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func read<Response: LightTransformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func update<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func update<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func partialUpdate<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func delete<Response: LightTransformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>
}

public extension LightRestClient {
    @discardableResult
    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
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
    func create<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    func read<Response: LightTransformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidLightTransformer(),
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    @discardableResult
    func update<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
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
    func update<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    func partialUpdate<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
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
    func delete<Response: LightTransformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidLightTransformer(),
            responseTransformer: responseTransformer,
            completion: completion
        )
    }
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension LightRestClient {
    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer
        )
    }

    func create<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    func read<Response: LightTransformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidLightTransformer(),
            responseTransformer: responseTransformer
        )
    }

    func update<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer
        )
    }

    func update<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    func partialUpdate<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .patch,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer
        )
    }

    func delete<Response: LightTransformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidLightTransformer(),
            responseTransformer: responseTransformer
        )
    }
}
