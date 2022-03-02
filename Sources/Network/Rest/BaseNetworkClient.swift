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
    public let baseUrl: URL
    public let requestAuthorizer: RequestAuthorizer?
    public let decoder: JSONDecoder
    public let encoder: JSONEncoder

    public init(
        http: Http,
        baseUrl: URL,
        requestAuthorizer: RequestAuthorizer? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.http = http
        self.baseUrl = baseUrl
        self.requestAuthorizer = requestAuthorizer
        self.decoder = decoder
        self.encoder = encoder
    }

    open func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: RequestSerializer.Value?,
        headers: [String: String],
        requestSerializer: RequestSerializer,
        responseSerializer: ResponseSerializer
    ) -> NetworkTask<ResponseSerializer.Value> {
        let task = InternalTask<ResponseSerializer> { [baseUrl, http, requestAuthorizer] task in
            let pathUrl = URL(string: path)
            let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)
            guard let url = pathUrlIsFull ? pathUrl : baseUrl.appendingPathComponent(path) else { return .failure(.badUrl) }

            let requestParameters = HttpRequestParameters(method: method, url: url, query: parameters, headers: headers)
            let requestResult = await http.request(parameters: requestParameters, object: object, serializer: requestSerializer)
            guard case .success(var request) = requestResult else {
                return .failure(.error(result: HttpResult(response: nil, data: nil, error: requestResult.error)))
            }

            var isPostAuth = false
            repeat {
                if let requestAuthorizer = requestAuthorizer {
                    let authResult = await requestAuthorizer.authorize(request: request, mode: isPostAuth ? .authError : .normal)
                    guard case .success(let authorizedRequest) = authResult else { return .failure(.auth(error: authResult.error)) }
                    request = authorizedRequest
                }

                let dataTask: HttpSerializedDataTask<ResponseSerializer> = http.data(request: request, serializer: responseSerializer)
                task.httpTask = dataTask
                let result = await dataTask.run()
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
        return task
    }

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
        guard let url = pathUrlIsFull ? pathUrl : baseUrl.appendingPathComponent(path) else { return .failure(.badUrl) }

        let requestParameters = HttpRequestParameters(method: method, url: url, query: parameters, headers: headers)
        let requestResult = await http.request(parameters: requestParameters, object: object, serializer: requestSerializer)
        guard case .success(var request) = requestResult else {
            return .failure(.error(result: HttpResult(response: nil, data: nil, error: requestResult.error)))
        }

        var isPostAuth = false
        repeat {
            if let requestAuthorizer = requestAuthorizer {
                let authResult = await requestAuthorizer.authorize(request: request, mode: isPostAuth ? .authError : .normal)
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

    open func request<Request: LightTransformer, Response: LightTransformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.T?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.T> {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelLightTransformerHttpSerializer(transformer: requestTransformer),
            responseSerializer: JsonModelLightTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

    open func request<Request: Transformer, Response: Transformer>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request.Destination?,
        headers: [String: String],
        requestTransformer: Request,
        responseTransformer: Response
    ) -> NetworkTask<Response.Destination> where Request.Source == Any, Response.Source == Any {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelTransformerHttpSerializer(transformer: requestTransformer),
            responseSerializer: JsonModelTransformerHttpSerializer(transformer: responseTransformer)
        )
    }

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

    open func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String],
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) -> NetworkTask<Response> {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            requestSerializer: JsonModelEncodableHttpSerializer<Request>(encoder: encoder),
            responseSerializer: JsonModelDecodableHttpSerializer<Response>(decoder: decoder)
        )
    }

    open func request<Request: Encodable, Response: Decodable>(
        method: HttpMethod,
        path: String,
        parameters: [String: String],
        object: Request?,
        headers: [String: String]
    ) -> NetworkTask<Response> {
        request(
            method: method,
            path: path,
            parameters: parameters,
            object: object,
            headers: headers,
            decoder: decoder,
            encoder: encoder
        )
    }

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
        func authorize(request: URLRequest, mode: RequestAuthorizerMode) async -> Result<URLRequest, Error> {
            .success(request)
        }
    }

    private class TaskProgress: HttpProgress {
        var data: HttpProgressData { progress?.data ?? HttpProgressData(bytes: nil, totalBytes: nil) }
        var callback: ((HttpProgressData) -> Void)?

        var progress: HttpProgress? {
            didSet {
                progress?.callback = callback
            }
        }
    }

    private class InternalTask<T: HttpSerializer>: NetworkTask<T.Value> {
        override var uploadProgress: HttpProgress { upload }
        override var downloadProgress: HttpProgress { download }

        var httpTask: HttpSerializedDataTask<T>? {
            didSet {
                upload.progress = httpTask?.uploadProgress
                download.progress = httpTask?.downloadProgress
            }
        }

        private var action: (InternalTask<T>) async -> Result<T.Value, NetworkError>
        private var upload: TaskProgress = TaskProgress()
        private var download: TaskProgress = TaskProgress()

        init(action: @escaping (InternalTask<T>) async -> Result<T.Value, NetworkError>) {
            self.action = action
        }

        override func run() async -> Result<T.Value, NetworkError> {
            await action(self)
        }
    }
}
