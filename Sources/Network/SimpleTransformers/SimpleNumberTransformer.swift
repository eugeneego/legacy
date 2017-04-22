//
// SimpleNumberTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct SimpleNumberTransformer<Number: NumberConvertible>: SimpleTransformer {
    public typealias T = Number

    public func from(any value: Any?) -> T? {
        return (value as? NSNumber).flatMap(T.fromNumber) ?? (value as? T)
    }

    public func to(any value: T?) -> Any? {
        return value?.toNumber()
    }
}
