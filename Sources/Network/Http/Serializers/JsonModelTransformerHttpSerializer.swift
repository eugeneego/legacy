//
// JsonModelTransformerHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct JsonModelLightTransformerHttpSerializer<T: LightTransformer>: HttpSerializer {
    public typealias Value = T.T

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Data? {
        return transformer.to(any: value).flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
    }

    public func deserialize(_ data: Data?) -> Value? {
        return transformer.from(any: data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) })
    }
}

public struct JsonModelForwardTransformerHttpSerializer<T: ForwardTransformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Data? {
        return nil
    }

    public func deserialize(_ data: Data?) -> Value? {
        guard
            let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let value = transformer.transform(source: json).value
        else { return nil }

        return value
    }
}

public struct JsonModelBackwardTransformerHttpSerializer<T: BackwardTransformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Data? {
        guard
            let value = value,
            let json = transformer.transform(destination: value).value,
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        else { return nil }

        return data
    }

    public func deserialize(_ data: Data?) -> Value? {
        return nil
    }
}

public struct JsonModelFullTransformerHttpSerializer<T: FullTransformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Data? {
        guard
            let value = value,
            let json = transformer.transform(destination: value).value,
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        else { return nil }

        return data
    }

    public func deserialize(_ data: Data?) -> Value? {
        guard
            let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let value = transformer.transform(source: json).value
        else { return nil }

        return value
    }
}
