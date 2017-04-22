//
// SimpleNumberStringTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct SimpleNumberStringTransformer<Number: NumberConvertible>: SimpleTransformer where Number: TransformerStringConvertible {
    public typealias T = Number

    private let numberTransformer = SimpleNumberTransformer<Number>()

    public func from(any value: Any?) -> T? {
        return numberTransformer.from(any: value) ?? (value as? String).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        return (numberTransformer.to(any: value) as? NSNumber)?.stringValue
    }
}
