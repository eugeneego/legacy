//
// RequestAuthorizer
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public protocol RequestAuthorizer {
    func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void)

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func authorize(request: URLRequest) async -> Result<URLRequest, Error>
}

extension RequestAuthorizer {
    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func authorize(request: URLRequest) async -> Result<URLRequest, Error> {
        await withCheckedContinuation { continuation in
            authorize(request: request, completion: continuation.resume(returning:))
        }
    }
}
