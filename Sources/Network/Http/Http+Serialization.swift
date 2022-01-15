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

    public init(response: HTTPURLResponse?, object: ObjectType?, data: DataType?, error: HttpError?) {
        self.response = response
        self.object = object
        self.data = data
        self.error = error
    }
}

public class HttpSerializedDataTask<T: HttpSerializer> {
    public typealias Result = HttpSerializedResult<T.Value, Data>
    public typealias Completion = (Result) -> Void

    public var uploadProgress: HttpProgress { task.uploadProgress }
    public var downloadProgress: HttpProgress { task.downloadProgress }
    public var completion: Completion?

    private let task: HttpDataTask
    private let serializer: T

    init(task: HttpDataTask, serializer: T) {
        self.task = task
        self.serializer = serializer

        task.completion = { result in
            let serializedResult = Routines.process(result: result, serializer: serializer)
            self.completion?(serializedResult)
            self.task.completion = nil
        }
    }

    public func resume() {
        task.resume()
    }

    public func cancel() {
        task.cancel()
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public func await() async -> Result {
        task.completion = nil
        let result = await task.await()
        let serializedResult = await Routines.process(result: result, serializer: serializer)
        return serializedResult
    }

    enum Routines {
        static func process(result: HttpResult<Data>, serializer: T) -> Result {
            var serializedResult = Result(response: result.response, object: nil, data: result.data, error: result.error)
            guard result.error == nil else { return serializedResult }

            switch serializer.deserialize(result.data) {
                case .success(let value):
                    serializedResult.object = value
                case .failure(let error):
                    serializedResult.error = .error(error)
            }
            return serializedResult
        }

        @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
        static func process(result: HttpResult<Data>, serializer: T) async -> Result {
            var serializedResult = Result(response: result.response, object: nil, data: result.data, error: result.error)
            guard result.error == nil else { return serializedResult }

            switch await serializer.deserialize(result.data) {
                case .success(let value):
                    serializedResult.object = value
                case .failure(let error):
                    serializedResult.error = .error(error)
            }
            return serializedResult
        }
    }
}

public extension Http {
    @discardableResult
    func data<T: HttpSerializer>(request: URLRequest, serializer: T) -> HttpSerializedDataTask<T> {
        HttpSerializedDataTask<T>(task: data(request: request), serializer: serializer)
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func data<T: HttpSerializer>(request: URLRequest, serializer: T) async -> HttpSerializedResult<T.Value, Data> {
        let result = await data(request: request)
        return await HttpSerializedDataTask<T>.Routines.process(result: result, serializer: serializer)
    }

    func request<T: HttpSerializer>(
        parameters: HttpRequestParameters,
        object: T.Value? = nil,
        serializer: T
    ) -> Result<URLRequest, HttpError> {
        serializer.serialize(object).map(
            success: { body in
                var parameters = parameters
                parameters.body = !body.isEmpty ? .data(body) : nil
                parameters.headers["Content-Type"] = serializer.contentType
                return .success(request(parameters: parameters))
            },
            failure: { .failure(.error($0)) }
        )
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func request<T: HttpSerializer>(
        parameters: HttpRequestParameters,
        object: T.Value? = nil,
        serializer: T
    ) async -> Result<URLRequest, HttpError> {
        await serializer.serialize(object).map(
            success: { body in
                var parameters = parameters
                parameters.body = !body.isEmpty ? .data(body) : nil
                parameters.headers["Content-Type"] = serializer.contentType
                return .success(request(parameters: parameters))
            },
            failure: { .failure(.error($0)) }
        )
    }
}
