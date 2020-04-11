//
// EnumTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct EnumCastLightTransformer<Enum: RawRepresentable>: LightTransformer {
    public typealias T = Enum

    public init() {}

    public func from(any value: Any?) -> T? {
        (value as? T.RawValue).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        value?.rawValue
    }
}

public struct EnumLightTransformer<Enum: RawRepresentable, RawTransformer: LightTransformer>: LightTransformer
        where RawTransformer.T == Enum.RawValue {
    public typealias T = Enum

    public let transformer: RawTransformer

    public init(transformer: RawTransformer) {
        self.transformer = transformer
    }

    public func from(any value: Any?) -> T? {
        transformer.from(any: value).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        transformer.to(any: value?.rawValue)
    }
}

public struct DictionaryEnumLightTransformer<Enum: Hashable, ValueTransformer: LightTransformer>: LightTransformer
        where ValueTransformer.T: Hashable {
    public typealias T = Enum
    public typealias Value = ValueTransformer.T

    public let transformer: ValueTransformer
    public let enumValueDictionary: [Enum: Value]
    public let valueEnumDictionary: [Value: Enum]

    public init(transformer: ValueTransformer, dictionary: [Enum: Value]) {
        self.transformer = transformer

        enumValueDictionary = dictionary

        valueEnumDictionary = dictionary.reduce([:]) { result, keyValue in
            var result = result
            result[keyValue.1] = keyValue.0
            return result
        }
    }

    public func from(any value: Any?) -> T? {
        transformer.from(any: value).flatMap { valueEnumDictionary[$0] }
    }

    public func to(any value: T?) -> Any? {
        value.flatMap { enumValueDictionary[$0] }.flatMap(transformer.to(any:))
    }
}
