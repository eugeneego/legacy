//
// ArrayLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct ArrayLightTransformer<ElementTransformer: LightTransformer>: LightTransformer {
    public typealias T = [ElementTransformer.T]

    private let transformer: ElementTransformer

    public init(transformer: ElementTransformer) {
        self.transformer = transformer
    }

    public func from(any value: Any?) -> T? {
        (value as? [Any])?.compactMap(transformer.from(any:))
    }

    public func to(any value: T?) -> Any? {
        value?.compactMap(transformer.to(any:))
    }
}
