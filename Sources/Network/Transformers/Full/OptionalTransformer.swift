//
// OptionalTransformer
// EEUtilities
//
// Created by Eugene Egorov on 24 April 2017.
//

import Foundation

public struct OptionalTransformer<ValueTransformer: FullTransformer>: FullTransformer {
    public typealias Source = ValueTransformer.Source?
    public typealias Destination = ValueTransformer.Destination?

    private let transformer: ValueTransformer

    public init(transformer: ValueTransformer) {
        self.transformer = transformer
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        if let value = value, !(value is NSNull) {
            return transformer.transform(source: value).map { $0 }
        } else {
            return .success(nil)
        }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        if let value = value {
            return transformer.transform(destination: value).map { $0 }
        } else {
            return .success(nil)
        }
    }
}
