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
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestSerializer.Value?,
        headers: [String: String],
        requestSerializer: RequestSerializer,
        responseSerializer: ResponseSerializer,
        completion: @escaping (Result<ResponseSerializer.Value, NetworkError>) -> Void
    ) -> NetworkTask {
        let task = InternalTask<ResponseSerializer>()

        let requestCompletion = { [completionQueue] (result: Result<ResponseSerializer.Value, NetworkError>) in
            completionQueue.async {
                completion(result)
            }
        }

        let pathUrl = URL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)
        guard let url = pathUrlIsFull ? pathUrl : baseURL.appendingPathComponent(path) else {
            requestCompletion(.failure(.badUrl))
            return task
        }

        let createRequest = { [http, workQueue] (createCompletion: @escaping (Result<URLRequest, HttpError>) -> Void) -> Void in
            workQueue.async {
                let requestParameters = HttpRequestParameters(method: method, url: url, query: parameters, headers: headers)
                let request = http.request(parameters: requestParameters, object: object, serializer: requestSerializer)
                DispatchQueue.main.async {
                    createCompletion(request)
                }
            }
        }

        let authorizeAndRunRequest = { [http] (authorizer: RequestAuthorizer, request: URLRequest, authFailure: (() -> Void)?) in
            authorizer.authorize(request: request) { result in
                switch result {
                    case .success(let request):
                        let httpTask = http.data(request: request, serializer: responseSerializer)
                        httpTask.completion = { result in
                            task.httpTask = nil
                            if case .status(let code, _)? = result.error {
                                if code == 401, let authFailure = authFailure {
                                    authFailure()
                                } else {
                                    requestCompletion(.failure(.http(code: code, result: result.httpResult)))
                                }
                            } else {
                                requestCompletion(Result(result.object, .error(result: result.httpResult)))
                            }
                        }
                        task.httpTask = httpTask
                        httpTask.resume()
                    case .failure(let error):
                        requestCompletion(.failure(.auth(error: error)))
                }
            }
        }

        createRequest { [requestAuthorizer] result in
            switch result {
                case .success(let request):
                    authorizeAndRunRequest(requestAuthorizer ?? EmptyRequestAuthorizer(), request, requestAuthorizer.map { authorizer in
                        { authorizeAndRunRequest(authorizer, request, nil) } // swiftlint:disable:this opening_brace
                    })
                case .failure(let error):
                    requestCompletion(.failure(.error(result: HttpResult(response: nil, data: nil, error: error))))
            }
        }

        return task
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    open func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestSerializer.Value?,
        headers: [String: String],
        requestSerializer: RequestSerializer,
        responseSerializer: ResponseSerializer
    ) async -> Result<ResponseSerializer.Value, NetworkError> {
        let pathUrl = URL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)
        guard let url = pathUrlIsFull ? pathUrl : baseURL.appendingPathComponent(path) else { return .failure(.badUrl) }

        let requestParameters = HttpRequestParameters(method: method, url: url, query: parameters, headers: headers)
        let requestResult = await http.request(parameters: requestParameters, object: object, serializer: requestSerializer)
        guard case .success(var request) = requestResult else {
            return .failure(.error(result: HttpResult(response: nil, data: nil, error: requestResult.error)))
        }

        var isPostAuth = false
        repeat {
            if let requestAuthorizer = requestAuthorizer {
                let authResult = await requestAuthorizer.authorize(request: request)
                guard case .success(let authorizedRequest) = authResult else { return .failure(.auth(error: authResult.error)) }
                request = authorizedRequest
            }

            let result = await http.data(request: request, serializer: responseSerializer)
            if case .status(let code, _)? = result.error {
                if code == 401 && requestAuthorizer != nil && !isPostAuth {
                    isPostAuth = true
                } else {
                    return .failure(.http(code: code, result: result.httpResult))
                }
            } else {
                return Result(result.object, .error(result: result.httpResult))
            }
        } while true
    }

    // Transformers

    @discardableResult
    open func request<Request: LightTransformer, Response: LightTransformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.T, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelLightTransformerHttpSerializer(transformer: requestTransformer),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @discardableResult
    open func request<Request: Transformer, Response: Transformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response,
        completion: @escaping (Result<Response.Destination, NetworkError>) -> Void
    ) -> NetworkTask where Request.Source == Any, Response.Source == Any {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelTransformerHttpSerializer(transformer: requestTransformer),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer),
            completion: completion
        )
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    open func request<Request: LightTransformer, Response: LightTransformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.T, NetworkError> {
        await request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelLightTransformerHttpSerializer(transformer: requestTransformer),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    open func request<Request: Transformer, Response: Transformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) async -> Result<Response.Destination, NetworkError> where Request.Source == Any, Response.Source == Any {
        await request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelTransformerHttpSerializer(transformer: requestTransformer),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    // Codable

    @discardableResult
    open func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String],
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelEncodableHttpSerializer<Request>(encoder: encoder),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder),
            completion: completion
        )
    }

    @discardableResult
    open func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String],
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) -> NetworkTask {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            decoder: decoder,
            encoder: encoder,
            completion: completion
        )
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    open func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String],
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) async -> Result<Response, NetworkError> {
        await request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelEncodableHttpSerializer<Request>(encoder: encoder),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder)
        )
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    open func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String]
    ) async -> Result<Response, NetworkError> {
        await request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            decoder: decoder,
            encoder: encoder
        )
    }

    // MARK: - Private

    private struct EmptyRequestAuthorizer: RequestAuthorizer {
        func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
            completion(.success(request))
        }
    }

    private class Progress: HttpProgress {
        var bytes: Int64? { progress?.bytes }
        var totalBytes: Int64? { progress?.totalBytes }
        var callback: ((HttpProgressData) -> Void)?

        var progress: HttpProgress? {
            didSet {
                progress?.callback = callback
            }
        }
    }

    private class InternalTask<T: HttpSerializer>: NetworkTask {
        var httpTask: HttpSerializedDataTask<T>?
        var uploadProgress: HttpProgress { upload }
        var downloadProgress: HttpProgress { download }

        var upload: Progress = Progress()
        var download: Progress = Progress()

        func cancel() {
            httpTask?.cancel()
        }
    }
}
