//
// SimpleRestClient
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public class SimpleRestClient: RestClient {
    public let http: Http
    public let baseURL: NSURL
    public let completionQueue: dispatch_queue_t

    public init(http: Http, baseURL: NSURL, completionQueue: dispatch_queue_t) {
        self.http = http
        self.baseURL = baseURL
        self.completionQueue = completionQueue
    }

    public func request<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        method method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
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

    public func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: (ResponseSerializer.Value?, ErrorType?) -> Void
    ) {
        let pathUrl = NSURL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme.isEmpty ?? true)
        guard let url = pathUrlIsFull ? pathUrl : baseURL.URLByAppendingPathComponent(path) else {
            completion(nil, HttpError.BadUrl)
            return
        }

        let request = http.request(
            method: method, url: url, urlParameters: parameters, headers: headers,
            object: object, serializer: requestSerializer
        )

        let queue = self.completionQueue

        http.data(request: request, serializer: responseSerializer) { response, object, error in
            dispatch_async(queue) {
                if let code = response?.statusCode where code >= 400 {
                    completion(object, RestError.Http(code: code, error: error))
                } else {
                    completion(object, error)
                }
            }
        }
    }

    private func pathWithId(path path: String, id: String?) -> String {
        let path = (path.isEmpty || path[path.startIndex] != "/") ? path : path.substringFromIndex(path.startIndex.successor())

        if let id = id {
            let delimiter = (!path.isEmpty && path[path.endIndex.predecessor()] != "/") ? "/" : ""
            return path + delimiter + id
        } else {
            return path
        }
    }

    public func create<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    ) {
        request(
            method: .Post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    public func create<ResponseTransformer: Transformer>(
        path path: String, id: String?, data: NSData?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    ) {
        request(
            method: .Post,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    public func read<ResponseTransformer: Transformer>(
        path path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    ) {
        request(
            method: .Get,
            path: pathWithId(path: path, id: id),
            parameters: parameters,
            object: nil,
            headers: headers,
            requestTransformer: VoidTransformer(),
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    public func update<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    ) {
        request(
            method: .Put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: object,
            headers: headers,
            requestTransformer: requestTransformer,
            responseTransformer: responseTransformer,
            completion: completion
        )
    }

    public func update<ResponseTransformer: Transformer>(
        path path: String, id: String?, data: NSData?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    ) {
        request(
            method: .Put,
            path: pathWithId(path: path, id: id),
            parameters: [:],
            object: data,
            headers: headers,
            requestSerializer: DataHttpSerializer(contentType: contentType),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    public func delete(
        path path: String, id: String?, headers: [String: String],
        completion: (Void?, ErrorType?) -> Void
    ) {
        request(
            method: .Delete,
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
