//
// DictionaryTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct DictionaryTransformer
        <KeyTransformer: Transformer, ValueTransformer: Transformer where KeyTransformer.T: Hashable>: Transformer {
    public typealias T = [KeyTransformer.T: ValueTransformer.T]

    public let keyTransformer: KeyTransformer
    public let valueTransformer: ValueTransformer

    public init(keyTransformer: KeyTransformer, valueTransformer: ValueTransformer) {
        self.keyTransformer = keyTransformer
        self.valueTransformer = valueTransformer
    }

    public func fromAny(value: AnyObject?) -> T? {
        guard let value = value as? [String: AnyObject] else { return nil }

        let dict: T = value.reduce([:]) { result, kv in
            var result = result
            if let key = keyTransformer.fromAny(kv.0), value = valueTransformer.fromAny(kv.1) {
                result[key] = value
            }
            return result
        }

        return dict
    }

    public func toAny(value: T?) -> AnyObject? {
        guard let value = value else { return nil }

        let dict: [String: AnyObject] = value.reduce([:]) { result, kv in
            var result = result
            if let key = keyTransformer.toAny(kv.0) as? String, value = valueTransformer.toAny(kv.1) {
                result[key] = value
            }
            return result
        }

        return dict
    }
}
