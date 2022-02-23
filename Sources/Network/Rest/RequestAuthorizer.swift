//
// RequestAuthorizer
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum RequestAuthorizerMode {
    case normal
    case authError
}

public protocol RequestAuthorizer {
    func authorize(request: URLRequest, mode: RequestAuthorizerMode) async -> Result<URLRequest, Error>
}
