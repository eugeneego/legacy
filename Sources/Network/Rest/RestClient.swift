//
// LightRestClient
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol RestClient: NetworkClient {
    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    func create<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    func read<Response: HttpSerializer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    func update<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    func update<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    func partialUpdate<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    func delete<Response: HttpSerializer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseSerializer: Response
    ) -> NetworkTask<Response.Value>

    // MARK: - Async

    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    func create<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    func read<Response: HttpSerializer>(
        path: String,
        id: String?,
        parameters: [String: String],
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    func update<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    func update<Response: HttpSerializer>(
        path: String,
        id: String?,
        data: Data?,
        contentType: String,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    func partialUpdate<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>

    func delete<Response: HttpSerializer>(
        path: String,
        id: String?,
        headers: [String: String],
        responseSerializer: Response
    ) async -> Result<Response.Value, NetworkError>
}

public extension RestClient {
    func pathWithId(path: String, id: String?) -> String {
        let path = path.first == "/" ? String(path.dropFirst()) : path
        if let id = id {
            let delimiter = (!path.isEmpty && path.last != "/") ? "/" : ""
            return path + delimiter + id
        } else {
            return path
        }
    }

    func create<Request: HttpSerializer, Response: HttpSerializer>(
        path: String,
        id: String?,
        object: Request.Value?,
        headers: [String: String],
        requestSerializer: Request,
        responseSerializer: Response
    ) -> NetworkTask<Response.Value> {
        request(
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
    ) -> NetworkTask<Response.Value> {
        request(
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
    ) -> NetworkTask<Response.Value> {
        request(
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
    ) -> NetworkTask<Response.Value> {
        request(
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
    ) -> NetworkTask<Response.Value> {
        request(
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
    ) -> NetworkTask<Response.Value> {
        request(
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
    ) -> NetworkTask<Response.Value> {
        request(
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
