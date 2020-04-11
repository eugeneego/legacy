//
// AsIsTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct AsIsTransformer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = From

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        .success(value)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        .success(value)
    }
}
