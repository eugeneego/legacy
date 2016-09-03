//
// ArrayTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct ArrayTransformer<ElementTransformer: Transformer>: Transformer {
    public typealias T = [ElementTransformer.T]

    public let transformer: ElementTransformer

    public init(transformer: ElementTransformer) {
        self.transformer = transformer
    }

    public func fromAny(value: AnyObject?) -> T? {
        return (value as? [AnyObject])?.flatMap(transformer.fromAny)
    }

    public func toAny(value: T?) -> AnyObject? {
        return value?.flatMap(transformer.toAny)
    }
}
