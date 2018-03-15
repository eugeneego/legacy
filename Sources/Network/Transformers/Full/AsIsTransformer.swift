//
// AsIsTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct AsIsTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = From

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        return .success(value)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return .success(value)
    }
}
