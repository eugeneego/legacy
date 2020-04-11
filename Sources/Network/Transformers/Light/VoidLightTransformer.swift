//
// VoidLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct VoidLightTransformer: LightTransformer {
    public typealias T = Void

    public init() {}

    public func from(any value: Any?) -> T? {
        ()
    }

    public func to(any value: T?) -> Any? {
        nil
    }
}
