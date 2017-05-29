//
// DecimalTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DecimalTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = Decimal

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let number = value as? NSNumber else { return .failure(.transform) }
        return TransformerResult(Decimal(string: "\(number)", locale: Locale(identifier: "en_US")), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(NSDecimalNumber(decimal: value) as? From, .transform)
    }
}
