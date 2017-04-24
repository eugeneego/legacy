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

    public func transform(source value: Source) -> TransformerResult<Destination> {
        return TransformerResult(value as? String, .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(value as? From, .transform)
    }
}
