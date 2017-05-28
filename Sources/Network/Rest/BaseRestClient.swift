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
    open let completionQueue: DispatchQueue
    open let requestAuthorizer: RequestAuthorizer?

    public init(http: Http, baseURL: URL, completionQueue: DispatchQueue, requestAuthorizer: RequestAuthorizer? = nil) {
        self.http = http
        self.baseURL = baseURL
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

        let queue = self.completionQueue
        let pathUrl = URL(string: path)
        let pathUrlIsFull = !(pathUrl?.scheme?.isEmpty ?? true)

        guard let url = pathUrlIsFull ? pathUrl : baseURL.appendingPathComponent(path) else {
            queue.async {
                completion(.failure(.badUrl))
            }
            return task
        }

        let request = http.request(
            method: method, url: url, urlParameters: parameters, headers: headers,
            object: object, serializer: requestSerializer
        )

        let runRequest = { (request: URLRequest) -> Void in
            let httpTask = self.http.data(request: request as URLRequest, serializer: responseSerializer) { _, object, data, error in
                queue.async {
                    if case .status(let code, let error)? = error {
                        completion(.failure(.http(code: code, error: error, body: data)))
                    } else {
                        completion(Result(object, .error(error: error, body: data)))
                    }
                    task.httpTask = nil
                }
            }
            task.httpTask = httpTask
            httpTask.resume()
        }

        if let requestAuthorizer = requestAuthorizer {
            requestAuthorizer.authorize(request: request) { result in
                switch result {
                    case .success(let request):
                        runRequest(request)
                    case .failure(let error):
                        queue.async {
                            completion(.failure(.auth(error: error)))
                        }
                }
            }
        } else {
            runRequest(request)
        }

        return Task()
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
