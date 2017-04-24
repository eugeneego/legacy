//
// TimestampTransformer
// EEUtilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct TimestampTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = Date

    private let numberTransformer = NumberTransformer<From, Int64>()

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        return numberTransformer.transform(source: value).map { Date(timeIntervalSince1970: TimeInterval($0)) }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return numberTransformer.transform(destination: Int64(value.timeIntervalSince1970))
    }
}
