//
// NumberStringTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation
import CoreGraphics

public struct NumberStringTransformer<Number: NumberConvertible>: Transformer where Number: TransformerStringConvertible {
    public typealias T = Number

    private let numberTransformer = NumberTransformer<Number>()

    public func from(any value: Any?) -> T? {
        return numberTransformer.from(any: value) ?? (value as? String).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        return (numberTransformer.to(any: value) as? NSNumber)?.stringValue
    }
}

public protocol TransformerStringConvertible {
    init?(_ text: String)
}

public protocol TransformerIntStringConvertible: TransformerStringConvertible {
    init?(_ text: String, radix: Int)
}

public extension TransformerIntStringConvertible {
    public init?(_ text: String) {
        self.init(text, radix: 10)
    }
}

extension Int: TransformerIntStringConvertible {}
extension Int8: TransformerIntStringConvertible {}
extension Int16: TransformerIntStringConvertible {}
extension Int32: TransformerIntStringConvertible {}
extension Int64: TransformerIntStringConvertible {}
extension UInt: TransformerIntStringConvertible {}
extension UInt8: TransformerIntStringConvertible {}
extension UInt16: TransformerIntStringConvertible {}
extension UInt32: TransformerIntStringConvertible {}
extension UInt64: TransformerIntStringConvertible {}

extension Float: TransformerStringConvertible {}
extension Double: TransformerStringConvertible {}

extension CGFloat: TransformerStringConvertible {
    public init?(_ text: String) {
        guard let double = Double(text) else { return nil }

        self.init(double)
    }
}
