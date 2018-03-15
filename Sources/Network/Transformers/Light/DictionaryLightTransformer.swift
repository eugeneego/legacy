//
// DictionaryLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct DictionaryLightTransformer
        <KeyTransformer: LightTransformer, ValueTransformer: LightTransformer>
        : LightTransformer where KeyTransformer.T: Hashable {
    public typealias T = [KeyTransformer.T: ValueTransformer.T]

    private let keyTransformer: KeyTransformer
    private let valueTransformer: ValueTransformer

    public init(keyTransformer: KeyTransformer, valueTransformer: ValueTransformer) {
        self.keyTransformer = keyTransformer
        self.valueTransformer = valueTransformer
    }

    public func from(any value: Any?) -> T? {
        guard let value = value as? [String: Any] else { return nil }

        let dict: T = value.reduce([:]) { result, element in
            var result = result
            if let key = keyTransformer.from(any: element.0), let value = valueTransformer.from(any: element.1) {
                result[key] = value
            }
            return result
        }

        return dict
    }

    public func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        let dict: [String: Any] = value.reduce([:]) { result, element in
            var result = result
            if let key = keyTransformer.to(any: element.0) as? String, let value = valueTransformer.to(any: element.1) {
                result[key] = value
            }
            return result
        }

        return dict
    }
}
