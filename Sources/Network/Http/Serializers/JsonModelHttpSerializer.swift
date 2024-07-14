//
// JsonModelHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum JsonModelTransformerHttpSerializerError: Error {
    case serialization(Error)
    case deserialization(Error)
    case transformation(Error?)
}

public struct JsonModelLightTransformerHttpSerializer<T: LightTransformer>: HttpSerializer {
    public typealias Value = T.T
    public typealias Error = JsonModelTransformerHttpSerializerError

    public let contentType: String = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = transformer.to(any: value) else { return .success(Data()) }
        return Result(
            catching: { try JSONSerialization.data(withJSONObject: value, options: []) },
            unknown: { HttpSerializationError.error(Error.serialization($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data, !data.isEmpty else {
            return Result(transformer.from(any: ()), HttpSerializationError.error(Error.transformation(nil)))
        }
        let json = Result(
            catching: { try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) },
            unknown: { HttpSerializationError.error(Error.deserialization($0)) }
        )
        return json.flatMap { json in
            Result(transformer.from(any: json), HttpSerializationError.error(Error.transformation(nil)))
        }
    }
}

public struct JsonModelTransformerHttpSerializer<T: Transformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination
    public typealias Error = JsonModelTransformerHttpSerializerError

    public let contentType: String = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value else { return .success(Data()) }

        let json = transformer.transform(destination: value)
        return json.map(
            success: { json in
                Result(
                    catching: { try JSONSerialization.data(withJSONObject: json, options: []) },
                    unknown: { HttpSerializationError.error(Error.serialization($0)) }
                )
            },
            failure: { .failure(HttpSerializationError.error(Error.transformation($0))) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data, !data.isEmpty else {
            return transformer.transform(source: ()).mapError { HttpSerializationError.error(Error.transformation($0)) }
        }
        let json = Result(
            catching: { try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) },
            unknown: { HttpSerializationError.error(Error.deserialization($0)) }
        )
        return json.flatMap { json in
            transformer.transform(source: json).mapError { HttpSerializationError.error(Error.transformation($0)) }
        }
    }
}

public enum JsonModelCodableHttpSerializerError: Error {
    case decoding(Error)
    case encoding(Error)
    case notSupported
}

public struct JsonModelCodableHttpSerializer<T: Codable & Sendable>: HttpSerializer {
    public typealias Value = T
    public typealias Error = JsonModelCodableHttpSerializerError

    public let contentType: String = "application/json"

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

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value else { return .success(Data()) }
        return Result(
            catching: { try encoder.encode(value) },
            unknown: { HttpSerializationError.error(Error.encoding($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        if let nilValue = Nil() as? Value {
            return .success(nilValue)
        }
        guard let data else { return .failure(.noData) }
        return Result(
            catching: { try decoder.decode(T.self, from: data) },
            unknown: { HttpSerializationError.error(Error.decoding($0)) }
        )
    }
}

public struct JsonModelDecodableHttpSerializer<T: Decodable & Sendable>: HttpSerializer {
    public typealias Value = T
    public typealias Error = JsonModelCodableHttpSerializerError

    public let contentType: String = "application/json"

    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    public init(
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        .failure(HttpSerializationError.error(Error.notSupported))
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        if let nilValue = Nil() as? Value {
            return .success(nilValue)
        }
        guard let data else { return .failure(.noData) }
        return Result(
            catching: { try decoder.decode(T.self, from: data) },
            unknown: { HttpSerializationError.error(Error.decoding($0)) }
        )
    }
}

public struct JsonModelEncodableHttpSerializer<T: Encodable & Sendable>: HttpSerializer {
    public typealias Value = T
    public typealias Error = JsonModelCodableHttpSerializerError

    public let contentType: String = "application/json"

    private let encoder: JSONEncoder

    public init(encoder: JSONEncoder) {
        self.encoder = encoder
    }

    public init(
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys,
        outputFormatting: JSONEncoder.OutputFormatting = []
    ) {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        encoder.keyEncodingStrategy = keyEncodingStrategy
        encoder.outputFormatting = outputFormatting
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value else { return .success(Data()) }
        return Result(
            catching: { try encoder.encode(value) },
            unknown: { HttpSerializationError.error(Error.encoding($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        .failure(HttpSerializationError.error(Error.notSupported))
    }
}

public struct Nil: Codable {
}
