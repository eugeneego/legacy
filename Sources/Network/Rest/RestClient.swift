//
// RestClient
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public enum RestError: ErrorType {
    case Http(code: Int, error: ErrorType?)
}

public protocol RestClient {
    var http: Http { get }
    var baseURL: NSURL { get }

    func request<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        method method: HttpMethod, path: String,
        parameters: [String: String], object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    )

    func request<RequestSerializer: HttpSerializer, ResponseSerializer: HttpSerializer>(
        method method: HttpMethod, path: String,
        parameters: [String: String], object: RequestSerializer.Value?, headers: [String: String],
        requestSerializer: RequestSerializer, responseSerializer: ResponseSerializer,
        completion: (ResponseSerializer.Value?, ErrorType?) -> Void
    )

    func create<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    )

    func create<ResponseTransformer: Transformer>(
        path path: String, id: String?, data: NSData?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    )

    func read<ResponseTransformer: Transformer>(
        path path: String, id: String?, parameters: [String: String], headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    )

    func update<RequestTransformer: Transformer, ResponseTransformer: Transformer>(
        path path: String, id: String?, object: RequestTransformer.T?, headers: [String: String],
        requestTransformer: RequestTransformer, responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    )

    func update<ResponseTransformer: Transformer>(
        path path: String, id: String?, data: NSData?, contentType: String, headers: [String: String],
        responseTransformer: ResponseTransformer,
        completion: (ResponseTransformer.T?, ErrorType?) -> Void
    )

    func delete(
        path path: String, id: String?, headers: [String: String],
        completion: (Void?, ErrorType?) -> Void
    )
}
