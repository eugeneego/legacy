//
// VoidTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct VoidTransformer: Transformer {
    public typealias T = Void

    public func fromAny(value: AnyObject?) -> T? {
        return value.flatMap { _ in () }
    }

    public func toAny(value: T?) -> AnyObject? {
        return nil
    }
}
