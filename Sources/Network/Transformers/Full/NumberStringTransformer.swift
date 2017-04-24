//
// NumberStringTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation
import CoreGraphics

public struct NumberStringTransformer<From, To: NumberConvertible & TransformerStringConvertible>: FullTransformer {
    public typealias Source = From
    public typealias Destination = To

    private let numberTransformer = NumberTransformer<From, To>()

    public init() {}

    public func convert(source value: Source) -> TransformerResult<Destination> {
        return numberTransformer.convert(source: value)
            .flatMapError { _ in TransformerResult((value as? String).flatMap(To.init), .transform) }
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        return numberTransformer.convert(destination: value)
            .flatMap { TransformerResult<Source>(($0 as? NSNumber)?.stringValue as? From, .transform) }
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
