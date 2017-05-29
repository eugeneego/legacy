//
// VoidHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct VoidHttpSerializer: HttpSerializer {
    public typealias Value = Any

    public let contentType = "application/json"

    public func serialize(_ value: Value?) -> Data? {
        return nil
    }

    public func deserialize(_ data: Data?) -> Value? {
        return nil
    }
}
