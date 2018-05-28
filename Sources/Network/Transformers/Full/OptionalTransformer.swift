//
// OptionalTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct OptionalTransformer<ValueTransformer: Transformer>: Transformer {
    public typealias Source = ValueTransformer.Source?
    public typealias Destination = ValueTransformer.Destination?

    private let transformer: ValueTransformer

    public init(transformer: ValueTransformer) {
        self.transformer = transformer
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        if let value = value, !(value is NSNull) {
            // swiftlint:disable:next array_init
            return transformer.transform(source: value).map { $0 }
        } else {
            return .success(nil)
        }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        if let value = value {
            // swiftlint:disable:next array_init
            return transformer.transform(destination: value).map { $0 }
        } else {
            return .success(nil)
        }
    }
}
