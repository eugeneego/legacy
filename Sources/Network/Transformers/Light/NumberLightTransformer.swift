//
// NumberLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct NumberLightTransformer<Number: NumberConvertible>: LightTransformer {
    public typealias T = Number

    public init() {}

    public func from(any value: Any?) -> T? {
        (value as? NSNumber).flatMap(T.fromNumber) ?? (value as? T)
    }

    public func to(any value: T?) -> Any? {
        value?.toNumber()
    }
}
