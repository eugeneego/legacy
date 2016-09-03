//
// Http
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public typealias HttpCompletion = (NSHTTPURLResponse?, NSData?, HttpError?) -> Void

public protocol Http {
    func data(request request: NSURLRequest, completion: HttpCompletion)

    func urlWithParameters(url url: NSURL, parameters: [String: String]) -> NSURL
    func request(method method: String, url: NSURL, urlParameters: [String: String],
        headers: [String: String], body: NSData?) -> NSMutableURLRequest
}

public enum HttpError: ErrorType {
    case NonHttpResponse(response: NSURLResponse)
    case BadUrl
    case ParsingFailed
    case Error(error: ErrorType?)
    case Status(code: Int, error: ErrorType?)
}

public enum HttpMethod {
    case Get
    case Head
    case Post
    case Put
    case Patch
    case Delete
    case Trace
    case Options
    case Connect
    case Custom(String)

    public var value: String {
        switch self {
            case Get: return "GET"
            case Head: return "HEAD"
            case Post: return "POST"
            case Put: return "PUT"
            case Patch: return "PATCH"
            case Delete: return "DELETE"
            case Trace: return "TRACE"
            case Options: return "OPTIONS"
            case Connect: return "CONNECT"
            case Custom(let value): return value
        }
    }
}

public extension Http {
    public func data(
        method method: HttpMethod, url: NSURL, urlParameters: [String: String],
        headers: [String: String], body: NSData?, completion: HttpCompletion
    ) {
        let req = request(method: method, url: url, urlParameters: urlParameters, headers: headers, body: body)
        data(request: req, completion: completion)
    }

    public func data<T: HttpSerializer>(
        request request: NSURLRequest, serializer: T,
        completion: (NSHTTPURLResponse?, T.Value?, HttpError?) -> Void
    ) {
        data(request: request) { response, data, error in
            let object = serializer.deserialize(data)
            var error = error
            if error == nil && object == nil {
                error = HttpError.ParsingFailed
            }
            completion(response, object, error)
        }
    }

    public func urlWithParameters(url url: NSURL, parameters: [String: String]) -> NSURL {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!

        if !parameters.isEmpty {
            let serializer = UrlEncodedHttpSerializer()
            var params = serializer.deserialize(components.query) ?? [:]
            parameters.forEach { key, value in
                params[key] = value
            }
            components.percentEncodedQuery = serializer.serialize(params)
        }

        return components.URL!
    }

    public func request(
        method method: String, url: NSURL, urlParameters: [String: String],
        headers: [String: String], body: NSData?
    ) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: urlWithParameters(url: url, parameters: urlParameters))
        request.HTTPMethod = method
        request.HTTPBody = body
        headers.forEach { name, value in
            request.setValue(value, forHTTPHeaderField: name)
        }
        return request
    }

    public func request(
        method method: HttpMethod, url: NSURL, urlParameters: [String: String],
        headers: [String: String], body: NSData?
    ) -> NSMutableURLRequest {
        return request(method: method.value, url: url, urlParameters: urlParameters, headers: headers, body: body)
    }

    public func request<T: HttpSerializer>(
        method method: HttpMethod, url: NSURL, urlParameters: [String: String],
        headers: [String: String],
        object: T.Value?, serializer: T
    ) -> NSMutableURLRequest {
        let req = request(method: method, url: url, urlParameters: urlParameters,
            headers: headers, body: serializer.serialize(object))
        if req.HTTPBody != nil {
            req.setValue(serializer.contentType, forHTTPHeaderField: "Content-Type")
        }
        return req
    }
}
