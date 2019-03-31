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
}
