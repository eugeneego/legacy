//
// HttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum HttpSerializationError: Error {
    case noData
    case error(Error)
}

public protocol HttpSerializer: Sendable {
    associatedtype Value: Sendable

    var contentType: String { get }

    func serialize(_ value: Value?) -> Result<Data, HttpSerializationError>
    func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError>

    func serialize(_ value: Value?) async -> Result<Data, HttpSerializationError>
    func deserialize(_ data: Data?) async -> Result<Value, HttpSerializationError>
}

public extension HttpSerializer {
    func serialize(_ value: Value?) async -> Result<Data, HttpSerializationError> {
        await HttpSerializerActor(serializer: self).serialize(value)
    }

    func deserialize(_ data: Data?) async -> Result<Value, HttpSerializationError> {
        await HttpSerializerActor(serializer: self).deserialize(data)
    }
}

private actor HttpSerializerActor<Serializer: HttpSerializer> {
    private let serializer: Serializer

    init(serializer: Serializer) {
        self.serializer = serializer
    }

    func serialize(_ value: Serializer.Value?) -> Result<Data, HttpSerializationError> {
        serializer.serialize(value)
    }

    func deserialize(_ data: Data?) -> Result<Serializer.Value, HttpSerializationError> {
        serializer.deserialize(data)
    }
}
