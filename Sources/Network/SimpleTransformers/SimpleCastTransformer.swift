//
// SimpleCastTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct SimpleCastTransformer<Object>: SimpleTransformer {
    public typealias T = Object

    public func from(any value: Any?) -> T? {
        return value as? T
    }

    public func to(any value: T?) -> Any? {
        return value
    }
}
