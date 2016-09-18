//
// VoidTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct VoidTransformer: Transformer {
    public typealias T = Void

    public func from(any value: Any?) -> T? {
        return ()
    }

    public func to(any value: T?) -> Any? {
        return nil
    }
}
