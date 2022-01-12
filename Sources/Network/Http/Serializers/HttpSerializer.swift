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

public protocol HttpSerializer {
    associatedtype Value

    var contentType: String { get }

    func serialize(_ value: Value?) -> Result<Data, HttpSerializationError>
    func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError>

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func serialize(_ value: Value?) async -> Result<Data, HttpSerializationError>

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func deserialize(_ data: Data?) async -> Result<Value, HttpSerializationError>
}

public extension HttpSerializer {
    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func serialize(_ value: Value?) async -> Result<Data, HttpSerializationError> {
        await HttpSerializerActor(serializer: self).serialize(value)
    }

    @available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
    func deserialize(_ data: Data?) async -> Result<Value, HttpSerializationError> {
        await HttpSerializerActor(serializer: self).deserialize(data)
    }
}

@available(iOS 13, tvOS 13, watchOS 6.0, macOS 10.15, *)
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
