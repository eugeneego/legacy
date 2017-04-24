//
// StringTransformer
// EEUtilities
//
// Created by Eugene Egorov on 24 April 2017.
//

public struct StringTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = String

    public init() {}

    public func convert(source value: Source) -> TransformerResult<Destination> {
        return TransformerResult(value as? String, .transform)
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(value as? From, .transform)
    }
}
