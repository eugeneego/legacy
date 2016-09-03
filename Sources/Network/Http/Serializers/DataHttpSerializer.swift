//
// DataHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DataHttpSerializer: HttpSerializer {
    public typealias Value = NSData

    public let contentType: String

    public init(contentType: String) {
        self.contentType = contentType
    }

    public func serialize(value: Value?) -> NSData? {
        return value
    }

    public func deserialize(data: NSData?) -> Value? {
        return data
    }
}
