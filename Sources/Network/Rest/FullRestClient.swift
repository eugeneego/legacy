//
// FullRestClient
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol FullRestClient: RestClient, FullNetworkClient {
    func create<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any

    func create<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any

    func read<Response: Transformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any

    func update<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any

    func update<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any

    func partialUpdate<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any

    func delete<Response: Transformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any

    // MARK: - Async

    func create<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any

    func create<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any

    func read<Response: Transformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any

    func update<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any

    func update<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any

    func partialUpdate<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any

    func delete<Response: Transformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any
}

public extension FullRestClient {
    func create<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any {
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

    func create<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    func read<Response: Transformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any {
        request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer<Any>(),
            responseTransformer: responseTransformer
        )
    }

    func update<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any {
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

    func update<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    func partialUpdate<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any {
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

    func delete<Response: Transformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Response.Source == Any {
        request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer<Any>(),
            responseTransformer: responseTransformer
        )
    }
}

public extension FullRestClient {
    func create<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any {
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

    func create<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any {
        await request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    func read<Response: Transformer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any {
        await request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer<Any>(),
            responseTransformer: responseTransformer
        )
    }

    func update<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any {
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

    func update<Response: Transformer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any {
        await request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    func partialUpdate<Request: Transformer, Response: Transformer>(
        path: String,
        id: String?,
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any {
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

    func delete<Response: Transformer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Response.Source == Any {
        await request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer<Any>(),
            responseTransformer: responseTransformer
        )
    }
}
