//
// NumberStringLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct NumberStringLightTransformer<Number: NumberConvertible & TransformerStringConvertible>: LightTransformer {
    public typealias T = Number

    private let numberTransformer: NumberLightTransformer = NumberLightTransformer<Number>()

    public init() {}

    public func from(any value: Any?) -> T? {
        numberTransformer.from(any: value) ?? (value as? String).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        (numberTransformer.to(any: value) as? NSNumber)?.stringValue
    }
}
