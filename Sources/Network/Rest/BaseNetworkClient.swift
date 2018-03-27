//
// BaseNetworkClient
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class BaseNetworkClient: NetworkClient {
    open let http: Http
    open let baseURL: URL
    open let workQueue: DispatchQueue
    open let completionQueue: DispatchQueue
    open let requestAuthorizer: RequestAuthorizer?

    public init(
        http: Http,
        baseURL: URL,
        workQueue: DispatchQueue,
        completionQueue: DispatchQueue,
        requestAuthorizer: RequestAuthorizer? = nil
    ) {
        self.http = http
        self.baseURL = baseURL
        self.workQueue = workQueue
        self.completionQueue = completionQueue
        self.requestAuthorizer = requestAuthorizer
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

        let requestCompletion = { result in
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

        let createRequest = { (createCompletion: @escaping (URLRequest) -> Void) -> Void in
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
                        let httpTask = http.data(request: request, serializer: responseSerializer) { response, object, _, error in
                            task.httpTask = nil

                            if case .status(let code, let error)? = error {
                                if code == 401, let authCompletion = authCompletion {
                                    authCompletion()
                                } else {
                                    requestCompletion(.failure(.http(code: code, error: error, response: response)))
                                }
                            } else {
                                requestCompletion(Result(object, .error(error: error, response: response)))
                            }
                        }
                        task.httpTask = httpTask
                        httpTask.resume()
                    case .failure(let error):
                        requestCompletion(.failure(.auth(error: error)))
                }
            }
        }

        createRequest { request in
            if let requestAuthorizer = requestAuthorizer {
                authorizeAndRunRequest(requestAuthorizer, request) {
                    authorizeAndRunRequest(requestAuthorizer, request, nil)
                }
            } else {
                let httpTask = http.data(request: request, serializer: responseSerializer) { response, object, _, error in
                    task.httpTask = nil

                    if case .status(let code, let error)? = error {
                        requestCompletion(.failure(.http(code: code, error: error, response: response)))
                    } else {
                        requestCompletion(Result(object, .error(error: error, response: response)))
                    }
                }
                task.httpTask = httpTask
                httpTask.resume()
            }
        }

        return task
    }

    private class Task: NetworkTask {
        var httpTask: HttpTask?

        init() {
        }

        func cancel() {
            httpTask?.cancel()
        }
    }
}
