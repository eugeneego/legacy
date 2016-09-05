//
// DictionaryTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public struct DictionaryTransformer
        <KeyTransformer: Transformer, ValueTransformer: Transformer>: Transformer where KeyTransformer.T: Hashable {
    public typealias T = [KeyTransformer.T: ValueTransformer.T]

    private let keyTransformer: KeyTransformer
    private let valueTransformer: ValueTransformer

    public init(keyTransformer: KeyTransformer, valueTransformer: ValueTransformer) {
        self.keyTransformer = keyTransformer
        self.valueTransformer = valueTransformer
    }

    public func fromAny(_ value: Any?) -> T? {
        guard let value = value as? [String: Any] else { return nil }

        let dict: T = value.reduce([:]) { result, kv in
            var result = result
            if let key = keyTransformer.fromAny(kv.0), let value = valueTransformer.fromAny(kv.1) {
                result[key] = value
            }
            return result
        }

        return dict
    }

    public func toAny(_ value: T?) -> Any? {
        guard let value = value else { return nil }

        let dict: [String: Any] = value.reduce([:]) { result, kv in
            var result = result
            if let key = keyTransformer.toAny(kv.0) as? String, let value = valueTransformer.toAny(kv.1) {
                result[key] = value
            }
            return result
        }

        return dict
    }
}
