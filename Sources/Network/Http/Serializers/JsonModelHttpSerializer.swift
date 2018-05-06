//
// JsonModelHttpSerializer
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

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = transformer.to(any: value) else { return .success(Data()) }

        return Result(
            try: { try JSONSerialization.data(withJSONObject: value, options: []) },
            unknown: HttpSerializationError.jsonSerialization
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data, !data.isEmpty else {
            return Result(transformer.from(any: ()), HttpSerializationError.noData)
        }

        let json = Result<Any, Error> { try JSONSerialization.jsonObject(with: data, options: .allowFragments) }
        return json.map(
            success: { Result(transformer.from(any: $0), HttpSerializationError.noData) },
            failure: { .failure(.jsonDeserialization($0)) }
        )
    }
}

public struct JsonModelForwardTransformerHttpSerializer<T: ForwardTransformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        return .failure(.noData)
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data, !data.isEmpty else {
            return transformer.transform(source: ()).mapError(HttpSerializationError.transformation)
        }

        let json = Result<Any, Error> { try JSONSerialization.jsonObject(with: data, options: .allowFragments) }
        return json.map(
            success: { transformer.transform(source: $0).mapError(HttpSerializationError.transformation) },
            failure: { .failure(.jsonDeserialization($0)) }
        )
    }
}

public struct JsonModelBackwardTransformerHttpSerializer<T: BackwardTransformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .success(Data()) }

        let json = transformer.transform(destination: value)
        return json.map(
            success: { json in
                Result(
                    try: { try JSONSerialization.data(withJSONObject: json, options: []) },
                    unknown: HttpSerializationError.jsonSerialization
                )
            },
            failure: { .failure(.transformation($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        return .failure(.noData)
    }
}

public struct JsonModelFullTransformerHttpSerializer<T: FullTransformer>: HttpSerializer where T.Source == Any {
    public typealias Value = T.Destination

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .success(Data()) }

        let json = transformer.transform(destination: value)
        return json.map(
            success: { json in
                Result(
                    try: { try JSONSerialization.data(withJSONObject: json, options: []) },
                    unknown: HttpSerializationError.jsonSerialization
                )
            },
            failure: { .failure(.transformation($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data, !data.isEmpty else {
            return transformer.transform(source: ()).mapError(HttpSerializationError.transformation)
        }

        let json = Result<Any, Error> { try JSONSerialization.jsonObject(with: data, options: .allowFragments) }
        return json.map(
            success: { transformer.transform(source: $0).mapError(HttpSerializationError.transformation) },
            failure: { .failure(.jsonDeserialization($0)) }
        )
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

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .success(Data()) }

        return Result(
            try: { try encoder.encode(value) },
            unknown: HttpSerializationError.jsonEncoder
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data else { return .failure(.noData) }

        return Result(
            try: { try decoder.decode(T.self, from: data) },
            unknown: HttpSerializationError.jsonDecoder
        )
    }
}

public struct NilCodableModel: Codable {
}
