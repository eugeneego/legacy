//
// ArrayTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct ArrayTransformer<From, ElementTransformer: Transformer>: Transformer {
    public typealias Source = From
    public typealias Destination = [ElementTransformer.Destination]

    private let transformer: ElementTransformer
    private let skipFailures: Bool

    public init(from: Source.Type = Source.self, transformer: ElementTransformer, skipFailures: Bool = true) {
        self.transformer = transformer
        self.skipFailures = skipFailures
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let source = value as? [ElementTransformer.Source] else { return .failure(.source) }

        let results = source.map(transformer.transform(source:))

        var destination: Destination = []
        var errors: [(String, TransformerError)] = []

        results.enumerated().forEach { index, result in
            switch result {
                case .success(let value):
                    destination.append(value)
                case .failure(let error):
                    errors.append((String(describing: index), error))
            }
        }

        if skipFailures || errors.isEmpty {
            return .success(destination)
        } else {
            return .failure(.multiple(errors))
        }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        let results = value.map(transformer.transform(destination:))

        var source: [ElementTransformer.Source] = []
        var errors: [(String, TransformerError)] = []

        results.enumerated().forEach { index, result in
            switch result {
                case .success(let value):
                    source.append(value)
                case .failure(let error):
                    errors.append((String(describing: index), error))
            }
        }

        if skipFailures || errors.isEmpty {
            return TransformerResult(source as? Source, .transform)
        } else {
            return .failure(.multiple(errors))
        }
    }
}
