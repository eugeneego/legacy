//
// NumberStringTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct NumberStringTransformer<From, To: NumberConvertible & TransformerStringConvertible>: Transformer {
    public typealias Source = From
    public typealias Destination = To

    private let numberTransformer: NumberTransformer = NumberTransformer<From, To>()

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        numberTransformer.transform(source: value)
            .flatMapError { _ in TransformerResult((value as? String).flatMap(To.init), .transform) }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        numberTransformer.transform(destination: value)
            .flatMap { TransformerResult<Source>(($0 as? NSNumber)?.stringValue as? From, .transform) }
    }
}
