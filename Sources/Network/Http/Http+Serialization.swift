//
// Http (Serialization)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct HttpSerializedResult<ObjectType, DataType> {
    public var response: HTTPURLResponse?
    public var object: ObjectType?
    public var data: DataType?
    public var error: HttpError?

    public var httpResult: HttpResult<DataType> {
        HttpResult(response: response, data: data, error: error)
    }
}

public class HttpSerializedDataTask<T: HttpSerializer> {
    public typealias Result = HttpSerializedResult<T.Value, Data>
    public typealias Completion = (Result) -> Void

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

        task.completion = { result in
            var serializedResult = Result(response: result.response, object: nil, data: result.data, error: result.error)
            if result.error == nil {
                switch serializer.deserialize(result.data) {
                    case .success(let value):
                        serializedResult.object = value
                    case .failure(let error):
                        serializedResult.error = .error(error)
                }
            }
            self.completion?(serializedResult)
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
