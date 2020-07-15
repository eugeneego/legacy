//
// JsonHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum JsonHttpSerializerError: Error {
    case serialization(Error)
    case deserialization(Error)
}

public struct JsonHttpSerializer: HttpSerializer {
    public typealias Value = Any
    public typealias Error = JsonHttpSerializerError

    public let contentType: String = "application/json"

    public init() {}

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .success(Data()) }

        return Result(
            catching: { try JSONSerialization.data(withJSONObject: value, options: []) },
            unknown: { HttpSerializationError.error(Error.serialization($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data, !data.isEmpty else { return .success([:]) }

        return Result(
            catching: { try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) },
            unknown: { HttpSerializationError.error(Error.deserialization($0)) }
        )
    }
}
