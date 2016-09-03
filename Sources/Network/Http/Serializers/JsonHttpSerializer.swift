//
// JsonHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct JsonHttpSerializer: HttpSerializer {
    public typealias Value = AnyObject

    public let contentType = "application/json"

    public func serialize(value: Value?) -> NSData? {
        return value.flatMap { try? NSJSONSerialization.dataWithJSONObject($0, options: []) }
    }

    public func deserialize(data: NSData?) -> Value? {
        return data.flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: .AllowFragments) }
    }
}
