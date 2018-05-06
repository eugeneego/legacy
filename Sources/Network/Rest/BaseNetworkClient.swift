//
// BaseNetworkClient
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class BaseNetworkClient: CodableNetworkClient {
    open let http: Http
    open let baseURL: URL
    open let workQueue: DispatchQueue
    open let completionQueue: DispatchQueue
    open let requestAuthorizer: RequestAuthorizer?
    open let decoder: JSONDecoder
    open let encoder: JSONEncoder

    public init(
        http: Http,
        baseURL: URL,
        workQueue: DispatchQueue,
        completionQueue: DispatchQueue,
        requestAuthorizer: RequestAuthorizer? = nil,
        decoder: JSONDecoder? = nil,
        encoder: JSONEncoder? = nil
    ) {
        self.http = http
        self.baseURL = baseURL
        self.workQueue = workQueue
        self.completionQueue = completionQueue
        self.requestAuthorizer = requestAuthorizer
        self.decoder = decoder ?? JSONDecoder()
        self.encoder = encoder ?? JSONEncoder()
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

    private class Progress: HttpProgress {
        var bytes: Int64? { return progress?.bytes }
        var totalBytes: Int64? { return progress?.totalBytes }
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
        var uploadProgress: HttpProgress { return upload }
        var downloadProgress: HttpProgress { return download }

        var upload: Progress = Progress()
        var download: Progress = Progress()

        init() {
        }

        func cancel() {
            httpTask?.cancel()
        }
    }
}
