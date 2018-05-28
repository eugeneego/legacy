//
// NumberStringTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import CoreGraphics

public struct NumberStringTransformer<From, To: TransformerStringConvertible>: Transformer {
    public typealias Source = From
    public typealias Destination = To

    private let numberTransformer = CastTransformer<From, To>()

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        return numberTransformer.transform(source: value)
            .flatMapError { _ in TransformerResult((value as? String).flatMap(To.init), .transform) }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return numberTransformer.transform(destination: value)
            .flatMap { TransformerResult<Source>(($0 as? NSNumber)?.stringValue as? From, .transform) }
    }
}

public protocol TransformerStringConvertible {
    init?(_ text: String)
}

extension Int: TransformerStringConvertible {}
extension Int8: TransformerStringConvertible {}
extension Int16: TransformerStringConvertible {}
extension Int32: TransformerStringConvertible {}
extension Int64: TransformerStringConvertible {}
extension UInt: TransformerStringConvertible {}
extension UInt8: TransformerStringConvertible {}
extension UInt16: TransformerStringConvertible {}
extension UInt32: TransformerStringConvertible {}
extension UInt64: TransformerStringConvertible {}

extension Float: TransformerStringConvertible {}
extension Double: TransformerStringConvertible {}

extension CGFloat: TransformerStringConvertible {
    public init?(_ text: String) {
        guard let double = Double(text) else { return nil }

        self.init(double)
    }
}
