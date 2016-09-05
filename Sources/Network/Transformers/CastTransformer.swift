//
// CastTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct CastTransformer<Object>: Transformer {
    public typealias T = Object

    public func fromAny(_ value: Any?) -> T? {
        return value as? T
    }

    public func toAny(_ value: T?) -> Any? {
        return value
    }
}
