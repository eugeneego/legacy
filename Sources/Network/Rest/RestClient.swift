//
// RestClient
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public enum RestError: Error {
    case badUrl
    case auth(error: AuthError?)
    case http(code: Int, error: Error?, body: Data?)
    case error(error: HttpError, body: Data?)
}

public protocol RestClient {
    var http: Http { get }
    var baseURL: URL { get }

    func request<RequestTransformer: SimpleTransformer, ResponseTransformer: SimpleTransformer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    )

    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: @escaping (ResponseSerializer.Value?, RestError?) -> Void
    )

    func create<RequestTransformer: SimpleTransformer, ResponseTransformer: SimpleTransformer>(
        path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    )

    func create<ResponseTransformer: SimpleTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    )

    func read<ResponseTransformer: SimpleTransformer>(
        path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    )

    func update<RequestTransformer: SimpleTransformer, ResponseTransformer: SimpleTransformer>(
        path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    )

    func update<ResponseTransformer: SimpleTransformer>(
        path: String, id: String?, data: Data?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: @escaping (ResponseTransformer.T?, RestError?) -> Void
    )

    func delete(
        path: String, id: String?, headers: [String: String],
        completion: @escaping (Void?, RestError?) -> Void
    )
}
