//
// JSON
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public class JSON {
    public let value: AnyObject?

    public init(value: AnyObject?) {
        self.value = value
    }

    public init(data: NSData?) {
        value = data.flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: .AllowFragments) }
    }

    public convenience init(string: String?) {
        self.init(data: string?.dataUsingEncoding(NSUTF8StringEncoding))
    }

    public convenience init(url: NSURL?) {
        self.init(data: url.flatMap(NSData.init))
    }

    public var dictionary: [String: AnyObject]? {
        return value as? [String: AnyObject]
    }

    public var array: [AnyObject]? {
        return value as? [AnyObject]
    }

    public var data: NSData? {
        return value.flatMap { try? NSJSONSerialization.dataWithJSONObject($0, options: []) }
    }
}
