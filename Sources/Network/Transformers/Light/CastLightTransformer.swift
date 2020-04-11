//
// CastLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct CastLightTransformer<Object>: LightTransformer {
    public typealias T = Object

    public init() {}

    public func from(any value: Any?) -> T? {
        value as? T
    }

    public func to(any value: T?) -> Any? {
        value
    }
}
