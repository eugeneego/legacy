//
// VoidTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct VoidTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = Void

    public init() {}

    public func convert(source value: Source) -> TransformerResult<Destination> {
        return TransformerResult((), .transform)
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(value as? From, .transform)
    }
}
