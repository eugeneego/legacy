//
// DictionaryTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct DictionaryTransformer
        <From, KeyTransformer: Transformer, ValueTransformer: Transformer>
        : Transformer where KeyTransformer.Source: Hashable, KeyTransformer.Destination: Hashable {
    public typealias Source = From
    public typealias Destination = [KeyTransformer.Destination: ValueTransformer.Destination]

    private let keyTransformer: KeyTransformer
    private let valueTransformer: ValueTransformer
    private let skipFailures: Bool

    public init(
        from: Source.Type = Source.self,
        keyTransformer: KeyTransformer,
        valueTransformer: ValueTransformer,
        skipFailures: Bool = true
    ) {
        self.keyTransformer = keyTransformer
        self.valueTransformer = valueTransformer
        self.skipFailures = skipFailures
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let source = value as? [KeyTransformer.Source: ValueTransformer.Source] else { return .failure(.source) }

        var destination: Destination = [:]
        var errors: [(String, TransformerError)] = []

        source.forEach { key, value in
            let keyResult = keyTransformer.transform(source: key)
            let valueResult = valueTransformer.transform(source: value)

            switch (keyResult, valueResult) {
                case (.success(let key), .success(let value)):
                    destination[key] = value
                default:
                    errors.append((String(describing: key), .transform))
            }
        }

        if skipFailures || errors.isEmpty {
            return .success(destination)
        } else {
            return .failure(.multiple(errors))
        }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        var source: [KeyTransformer.Source: ValueTransformer.Source] = [:]
        var errors: [(String, TransformerError)] = []

        value.forEach { key, value in
            let keyResult = keyTransformer.transform(destination: key)
            let valueResult = valueTransformer.transform(destination: value)

            switch (keyResult, valueResult) {
                case (.success(let key), .success(let value)):
                    source[key] = value
                default:
                    errors.append((String(describing: key), .transform))
            }
        }

        if skipFailures || errors.isEmpty {
            return TransformerResult(source as? Source, .transform)
        } else {
            return .failure(.multiple(errors))
        }
    }
}
