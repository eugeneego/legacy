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

    private let valueTransformer: ValueTransformer

    public init(valueTransformer: ValueTransformer) {
        self.valueTransformer = valueTransformer
    }

    public func convert(source value: Source) -> TransformerResult<Destination> {
        if let value = value, !(value is NSNull) {
            return valueTransformer.convert(source: value).map { $0 }
        } else {
            return .success(nil)
        }
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        if let value = value {
            return valueTransformer.convert(destination: value).map { $0 }
        } else {
            return .success(nil)
        }
    }
}
