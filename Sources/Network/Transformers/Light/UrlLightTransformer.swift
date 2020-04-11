//
// UrlLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct UrlLightTransformer: LightTransformer {
    public typealias T = URL

    public init() {}

    public func from(any value: Any?) -> T? {
        (value as? String).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        value?.absoluteString
    }
}
