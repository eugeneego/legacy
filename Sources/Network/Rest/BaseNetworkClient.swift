//
// BaseNetworkClient
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class BaseNetworkClient: LightNetworkClient, FullNetworkClient, CodableNetworkClient {
    public let http: Http
    public let baseURL: URL
    public let workQueue: DispatchQueue
    public let completionQueue: DispatchQueue
    public let requestAuthorizer: RequestAuthorizer?
    public let decoder: JSONDecoder
    public let encoder: JSONEncoder

    public init(
        http: Http,
        baseURL: URL,
        workQueue: DispatchQueue,
        completionQueue: DispatchQueue,
        requestAuthorizer: RequestAuthorizer? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.http = http
        self.baseURL = baseURL
        self.workQueue = workQueue
        self.completionQueue = completionQueue
        self.requestAuthorizer = requestAuthorizer
        self.decoder = decoder
        self.encoder = encoder
    }

    @discardableResult
    open func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        let task = Task()

        let http = self.http
        let baseUrl = self.baseURL
        let workQueue = self.workQueue
        let completionQueue = self.completionQueue
        let requestAuthorizer = self.requestAuthorizer

        let requestCompletion = { (result: Result<ResponseSerializer.Value, NetworkError>) in
            completionQueue.async {
                completion(result)
            }
        }

        let pathUrl = URL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)
        guard let url = pathUrlIsFull ? pathUrl : baseUrl.appendingPathComponent(path) else {
            requestCompletion(.failure(.badUrl))
            return task
        }

        let createRequest = { (createCompletion: @escaping (Result<URLRequest, HttpError>) -> Void) -> Void in
            workQueue.async {
                let request = http.request(
                    method: method, url: url, urlParameters: parameters, headers: headers,
                    object: object, serializer: requestSerializer
                )
                DispatchQueue.main.async {
                    createCompletion(request)
                }
            }
        }

        let authorizeAndRunRequest = { (authorizer: RequestAuthorizer, request: URLRequest, authCompletion: (() -> Void)?) in
            authorizer.authorize(request: request) { result in
                switch result {
                    case .success(let request):
                        let httpTask = http.data(request: request, serializer: responseSerializer) { response, object, data, error in
                            task.httpTask = nil

                            if case .status(let code, let error)? = error {
                                if code == 401, let authCompletion = authCompletion {
                                    authCompletion()
                                } else {
                                    requestCompletion(.failure(.http(code: code, error: error, response: response, data: data)))
                                }
                            } else {
                                requestCompletion(Result(object, .error(error: error, response: response, data: data)))
                            }
                        }
                        task.httpTask = httpTask
                        httpTask.resume()
                    case .failure(let error):
                        requestCompletion(.failure(.auth(error: error)))
                }
            }
        }

        createRequest { result in
            switch result {
                case .success(let request):
                    if let requestAuthorizer = requestAuthorizer {
                        authorizeAndRunRequest(requestAuthorizer, request) {
                            authorizeAndRunRequest(requestAuthorizer, request, nil)
                        }
                    } else {
                        let httpTask = http.data(request: request, serializer: responseSerializer) { response, object, data, error in
                            task.httpTask = nil

                            if case .status(let code, let error)? = error {
                                requestCompletion(.failure(.http(code: code, error: error, response: response, data: data)))
                            } else {
                                requestCompletion(Result(object, .error(error: error, response: response, data: data)))
                            }
                        }
                        task.httpTask = httpTask
                        httpTask.resume()
                    }
                case .failure(let error):
                    requestCompletion(.failure(.error(error: error, response: nil, data: nil)))
            }
        }

        return task
    }

    // Transformers

    @discardableResult
    open func request<RequestTransformer: LightTransformer, ResponseTransformer: LightTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.T, NetworkError>) -> Void
    ) -> NetworkTask {
        let requestSerializer = JsonModelLightTransformerHttpSerializer(transformer: requestTransformer)
        let responseSerializer = JsonModelLightTransformerHttpSerializer(transformer: responseTransformer)
        return request(
            method: method, path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    open func request<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.Destination?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (Result<ResponseTransformer.Destination, NetworkError>) -> Void
    ) -> NetworkTask where RequestTransformer.Source == Any, ResponseTransformer.Source == Any {
        let requestSerializer = JsonModelTransformerHttpSerializer(transformer: requestTransformer)
        let responseSerializer = JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        return request(
            method: method, path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }

    // Codable

    @discardableResult
    open func request<RequestObject: Encodable, ResponseObject: Decodable>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestObject?, headers: [String: String],
        decoder: JSONDecoder, encoder: JSONEncoder,
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        let requestSerializer = JsonModelEncodableHttpSerializer<RequestObject>(encoder: encoder)
        let responseSerializer = JsonModelDecodableHttpSerializer<ResponseObject>(decoder: decoder)
        return request(
            method: method, path: path, parameters: parameters, object: object, headers: headers,
            requestSerializer: requestSerializer, responseSerializer: responseSerializer,
            completion: completion
        )
    }

    @discardableResult
    open func request<RequestObject: Encodable, ResponseObject: Decodable>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestObject?, headers: [String: String],
        completion: @escaping (Result<ResponseObject, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: method, path: path, parameters: parameters, object: object, headers: headers,
            decoder: decoder, encoder: encoder,
            completion: completion
        )
    }

    private class Progress: HttpProgress {
        var bytes: Int64? { progress?.bytes }
        var totalBytes: Int64? { progress?.totalBytes }
        var callback: HttpProgressCallback?

        var progress: HttpProgress? {
            didSet {
                progress?.setCallback(callback)
            }
        }

        func setCallback(_ callback: HttpProgressCallback?) {
            self.callback = callback
        }
    }

    private class Task: NetworkTask {
        var httpTask: HttpTask?
        var uploadProgress: HttpProgress { upload }
        var downloadProgress: HttpProgress { download }

        var upload: Progress = Progress()
        var download: Progress = Progress()

        init() {
        }

        func cancel() {
            httpTask?.cancel()
        }
    }
}
