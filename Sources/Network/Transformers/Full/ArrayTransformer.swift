//
// ArrayTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct ArrayTransformer<From, ElementTransformer: FullTransformer>: FullTransformer {
    public typealias Source = From
    public typealias Destination = [ElementTransformer.Destination]

    private let transformer: ElementTransformer
    private let skipElements: Bool

    public init(transformer: ElementTransformer, skipElements: Bool) {
        self.transformer = transformer
        self.skipElements = skipElements
    }

    public func convert(source value: Source) -> TransformerResult<Destination> {
        guard let results = (value as? [ElementTransformer.Source])?.flatMap(transformer.convert(source:))
        else { return .failure(.transform) }

        if skipElements {
            return TransformerResult(results.flatMap { $0.value }, .transform)
        }

        let errors = results.flatMap { $0.error }
        if errors.count > 0 {
            return .failure(.transform)
        } else {
            return TransformerResult(results.flatMap { $0.value }, .transform)
        }
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(value.flatMap { transformer.convert(destination: $0).value } as? From, .transform)
    }
}
