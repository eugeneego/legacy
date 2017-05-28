//
// RequestAuthorizer
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public protocol AuthError: Error {}

public protocol RequestAuthorizer {
    func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, AuthError>) -> Void)
}
