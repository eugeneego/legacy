//
// ArrayLightTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct ArrayLightTransformer<ElementTransformer: LightTransformer>: LightTransformer {
    public typealias T = [ElementTransformer.T]

    private let transformer: ElementTransformer

    public init(transformer: ElementTransformer) {
        self.transformer = transformer
    }

    public func from(any value: Any?) -> T? {
        return (value as? [Any])?.flatMap(transformer.from(any:))
    }

    public func to(any value: T?) -> Any? {
        return value?.flatMap(transformer.to(any:))
    }
}
