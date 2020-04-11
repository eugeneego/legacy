//
// VoidTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct VoidTransformer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = Void

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        TransformerResult((), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        TransformerResult(value as? From, .transform)
    }
}
