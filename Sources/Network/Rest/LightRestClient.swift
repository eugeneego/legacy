//
// LightRestClient
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol LightRestClient: RestClient, LightNetworkClient {
    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    func create<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    func read<Response: LightTransformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    func update<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    func update<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    func partialUpdate<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    func delete<Response: LightTransformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.T>

    // MARK: - Async

    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    func create<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    func read<Response: LightTransformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    func update<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    func update<Response: LightTransformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    func partialUpdate<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>

    func delete<Response: LightTransformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError>
}

public extension LightRestClient {
    func create<Request: LightTransformer, Response: LightTransformer>(
        path: String,
        id: String?,
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.T> {
        request(
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
    ) -> NetworkTask<Response.T> {
        request(
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
    ) -> NetworkTask<Response.T> {
        request(
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
    ) -> NetworkTask<Response.T> {
        request(
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
    ) -> NetworkTask<Response.T> {
        request(
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
    ) -> NetworkTask<Response.T> {
        request(
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
    ) -> NetworkTask<Response.T> {
        request(
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
