//
// UrlTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct UrlTransformer: Transformer {
    public typealias T = NSURL

    public func fromAny(value: AnyObject?) -> T? {
        return (value as? String).flatMap(T.init)
    }

    public func toAny(value: T?) -> AnyObject? {
        return value?.absoluteString
    }
}
