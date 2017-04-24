//
// LightRestClient
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

open class LightRestClient: RestClient {
    open let http: Http
    open let baseURL: URL
    open let completionQueue: DispatchQueue
    open let requestAuthorizer: RequestAuthorizer?

    public init(http: Http, baseURL: URL, completionQueue: DispatchQueue, requestAuthorizer: RequestAuthorizer? = nil) {
        self.http = http
        self.baseURL = baseURL
        self.completionQueue = completionQueue
        self.requestAuthorizer = requestAuthorizer
    }

    open func request<RequestTransformer: LightTransformer, ResponseTransformer: LightTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
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
        completion: @escaping (ResponseSerializer.Value?, RestError?) -> Void
    ) {
        let pathUrl = URL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)
        guard let url = pathUrlIsFull ? pathUrl : baseURL.appendingPathComponent(path) else {
            completion(nil, .badUrl)
            return
        }

        let request = http.request(
            method: method, url: url, urlParameters: parameters, headers: headers,
            object: object, serializer: requestSerializer
        )

        let queue = self.completionQueue

        let runRequest = { (request: URLRequest) in
            self.http.data(request: request as URLRequest, serializer: responseSerializer) { _, object, data, error in
                queue.async {
                    if case .status(let code, let error)? = error {
                        completion(object, .http(code: code, error: error, body: data))
                    } else {
                        completion(object, error.map { .error(error: $0, body: data) })
                    }
                }
            }
        }

        if let requestAuthorizer = requestAuthorizer {
            requestAuthorizer.authorize(request: request) { request, error in
                if let request = request {
                    runRequest(request)
                } else {
                    queue.async {
                        completion(nil, .auth(error: error))
                    }
                }
            }
        } else {
            runRequest(request)
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

    open func create<RequestTransformer: LightTransformer, ResponseTransformer: LightTransformer>(
        path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
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

    open func create<ResponseTransformer: LightTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
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

    open func read<ResponseTransformer: LightTransformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    ) {
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

    open func update<RequestTransformer: LightTransformer, ResponseTransformer: LightTransformer>(
        path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
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

    open func update<ResponseTransformer: LightTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
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
        completion: @escaping (Void?, RestError?) -> Void
    ) {
        request(
            method: .delete,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: nil,
            headers: headers,
            requestTransformer: VoidLightTransformer(),
            responseTransformer: VoidLightTransformer(),
            completion: completion
        )
    }
}
