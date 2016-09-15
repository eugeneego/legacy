//
// HttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public protocol HttpSerializer {
    associatedtype Value

    var contentType: String { get }

    func serialize(_ value: Value?) -> Data?
    func deserialize(_ data: Data?) -> Value?
}
