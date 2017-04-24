//
// EnumTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct EnumCastTransformer<Enum: RawRepresentable>: LightTransformer {
    public typealias T = Enum

    public func from(any value: Any?) -> T? {
        return (value as? T.RawValue).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        return value?.rawValue
    }
}

public struct EnumTransformer<Enum: RawRepresentable, RawTransformer: LightTransformer>:
        LightTransformer where RawTransformer.T == Enum.RawValue {
    public typealias T = Enum

    public let transformer: RawTransformer

    public init(transformer: RawTransformer) {
        self.transformer = transformer
    }

    public func from(any value: Any?) -> T? {
        return transformer.from(any: value).flatMap(T.init)
    }

    public func to(any value: T?) -> Any? {
        return transformer.to(any: value?.rawValue)
    }
}

public struct DictionaryEnumTransformer<Enum: Hashable, ValueTransformer: LightTransformer>:
        LightTransformer where ValueTransformer.T: Hashable {
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
        return transformer.from(any: value).flatMap { valueEnumDictionary[$0] }
    }

    public func to(any value: T?) -> Any? {
        return value.flatMap { enumValueDictionary[$0] }.flatMap(transformer.to(any:))
    }
}
