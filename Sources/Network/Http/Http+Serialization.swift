//
// Http (Serialization)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public class HttpSerializedDataTask<T: HttpSerializer> {
    public typealias Completion = (HTTPURLResponse?, T.Value?, Data?, HttpError?) -> Void

    public var uploadProgress: HttpProgress { task.uploadProgress }
    public var downloadProgress: HttpProgress { task.downloadProgress }
    public var completion: Completion?

    private let task: HttpDataTask

    public func resume() {
        task.resume()
    }

    public func cancel() {
        task.cancel()
    }

    init(task: HttpDataTask, serializer: T) {
        self.task = task

        task.completion = { response, data, error in
            if let error = error {
                self.completion?(response, nil, data, error)
            } else {
                let result = serializer.deserialize(data)
                switch result {
                    case .success(let value):
                        self.completion?(response, value, data, error)
                    case .failure(let error):
                        self.completion?(response, nil, data, .error(error))
                }
            }
            self.task.completion = nil
        }
    }
}

public extension Http {
    @discardableResult
    func data<T: HttpSerializer>(request: URLRequest, serializer: T) -> HttpSerializedDataTask<T> {
        HttpSerializedDataTask<T>(task: data(request: request), serializer: serializer)
    }

    func request<T: HttpSerializer>(
        method: HttpMethod,
        url: URL,
        urlParameters: [String: String] = [:],
        headers: [String: String] = [:],
        object: T.Value? = nil,
        serializer: T
    ) -> Result<URLRequest, HttpError> {
        let body = serializer.serialize(object)
        return body.map(
            success: { body in
                let data: HttpBody? = !body.isEmpty ? .data(body) : nil
                var req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: data)
                req.setValue(serializer.contentType, forHTTPHeaderField: "Content-Type")
                return .success(req)
            },
            failure: { .failure(.error($0)) }
        )
    }
}
