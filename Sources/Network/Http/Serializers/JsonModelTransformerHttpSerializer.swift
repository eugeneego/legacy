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

public struct JsonModelCodableHttpSerializer<T: Codable>: HttpSerializer {
    public typealias Value = T

    public let contentType = "application/json"

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = decoder
        self.encoder = encoder
    }

    public init(
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
        outputFormatting: JSONEncoder.OutputFormatting = []
    ) {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.outputFormatting = outputFormatting
    }

    public func serialize(_ value: Value?) -> Data? {
        guard let value = value else { return nil }

        let data = try? encoder.encode(value)
        return data
    }

    public func deserialize(_ data: Data?) -> Value? {
        guard let data = data else { return nil }

        let object = try? decoder.decode(T.self, from: data)
        return object
    }
}

public struct NilCodableModel: Codable {}
