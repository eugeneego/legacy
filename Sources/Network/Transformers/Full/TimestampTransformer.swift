//
// TimestampTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct TimestampTransformer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = Date

    private let numberTransformer: NumberTransformer = NumberTransformer<From, Int64>()
    private let scale: TimeInterval

    public init(scale: TimeInterval = 1) {
        self.scale = scale
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        numberTransformer.transform(source: value).map { Date(timeIntervalSince1970: TimeInterval($0) * scale) }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        numberTransformer.transform(destination: Int64(value.timeIntervalSince1970 / scale))
    }
}
