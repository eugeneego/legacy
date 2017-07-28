//
// BaseRestClient
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

open class BaseRestClient: LightRestClient, FullRestClient {
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
        completion: @escaping (Result<ResponseSerializer.Value, RestError>) -> Void
    ) -> RestTask {
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
                createCompletion(request)
            }
        }

        var authorizeAndRunRequest = { (request: URLRequest, error: RestError?) in }

        let runRequest = { (request: URLRequest) -> Void in
            let httpTask = self.http.data(request: request as URLRequest, serializer: responseSerializer) { _, object, data, error in
                task.httpTask = nil

                if case .status(let code, let error)? = error {
                    if code == 401, requestAuthorizer != nil {
                        authorizeAndRunRequest(request, .http(code: code, error: error, body: data))
                    } else {
                        requestCompletion(.failure(.http(code: code, error: error, body: data)))
                    }
                } else {
                    requestCompletion(Result(object, .error(error: error, body: data)))
                }
            }
            task.httpTask = httpTask
            httpTask.resume()
        }

        authorizeAndRunRequest = { (request: URLRequest, error: RestError?) in
            DispatchQueue.main.async {
                if let requestAuthorizer = requestAuthorizer {
                    requestAuthorizer.authorize(request: request) { result in
                        switch result {
                            case .success(let request):
                                runRequest(request)
                            case .failure(let error):
                                requestCompletion(.failure(.auth(error: error)))
                        }
                    }
                } else {
                    runRequest(request)
                }
            }
        }

        createRequest { request in
            authorizeAndRunRequest(request, nil)
        }

        return task
    }

    private class Task: RestTask {
        var httpTask: HttpTask?

        init() {
        }

        func cancel() {
            httpTask?.cancel()
        }
    }
}
