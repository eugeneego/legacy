//
// NumberTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct NumberTransformer<From, To: NumberConvertible>: Transformer {
    public typealias Source = From
    public typealias Destination = To

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        TransformerResult((value as? NSNumber).flatMap(To.fromNumber) ?? (value as? To), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        TransformerResult(value.toNumber() as? From, .transform)
    }
}
