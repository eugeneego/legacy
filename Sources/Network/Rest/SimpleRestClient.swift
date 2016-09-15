//
// SimpleRestClient
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

open class SimpleRestClient: RestClient {
    open let http: Http
    open let baseURL: URL
    open let completionQueue: DispatchQueue

    public init(http: Http, baseURL: URL, completionQueue: DispatchQueue) {
        self.http = http
        self.baseURL = baseURL
        self.completionQueue = completionQueue
    }

    open func request<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, Error?) -> Void
    ) {
        let requestSerializer = JsonModelTransformerHttpSerializer(transformer: requestTransformer)
        let responseSerializer = JsonModelTransformerHttpSerializer(transformer: responseTransformer)

        request(
            method: method,
            path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }

    open func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (ResponseSerializer.Value?, Error?) -> Void
    ) {
        let pathUrl = URL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)
        guard let url = pathUrlIsFull ? pathUrl : baseURL.appendingPathComponent(path) else {
            completion(nil, HttpError.badUrl)
            return
        }

        let request = http.request(
            method: method, url: url, urlParameters: parameters, headers: headers,
            object: object, serializer: requestSerializer
        )

        let queue = self.completionQueue

        http.data(request: request as URLRequest, serializer: responseSerializer) { response, object, error in
            queue.async {
                if let code = response?.statusCode, code >= 400 {
                    completion(object, RestError.http(code: code, error: error))
                } else {
                    completion(object, error)
                }
            }
        }
    }

    private func pathWithId(path: String, id: String?) -> String {
        let path = (path.isEmpty || path[path.startIndex] != "/") ? path : path.substring(from: path.index(after: path.startIndex))

        if let id = id {
            let delimiter = (!path.isEmpty && path[path.characters.index(before: path.endIndex)] != "/") ? "/" : ""
            return path + delimiter + id
        } else {
            return path
        }
    }

    open func create<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, Error?) -> Void
    ) {
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

    open func create<ResponseTransformer: Transformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, Error?) -> Void
    ) {
        request(
            method: .post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    open func read<ResponseTransformer: Transformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, Error?) -> Void
    ) {
        request(
            method: .get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer(),
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    open func update<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, Error?) -> Void
    ) {
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

    open func update<ResponseTransformer: Transformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, Error?) -> Void
    ) {
        request(
            method: .put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    open func delete(
        path: String, id: String?, headers: [String: String],
        completion: @escaping (Void?, Error?) -> Void
    ) {
        request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer(),
            responseTransformer: VoidTransformer(),
            completion: completion
        )
    }
}
