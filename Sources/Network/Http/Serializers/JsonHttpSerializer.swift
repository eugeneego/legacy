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

public enum CommonError: Error {
    case unknown(String)
}

public struct JsonHttpSerializer: HttpSerializer {
    public typealias Value = AnySendableHolder
    public typealias Error = JsonHttpSerializerError

    public let contentType: String = "application/json"

    public init() {}

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value else { return .success(Data()) }
        return Result(
            catching: { try JSONSerialization.data(withJSONObject: value.value, options: []) },
            unknown: { .error(Error.serialization($0)) }
        )
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data, !data.isEmpty else { return .success(Value(value: ())) }
        return Result(
            catching: {
                let value = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                return Value(value: value)
            },
            unknown: { .error(Error.deserialization($0)) }
        )
    }
}

public struct AnySendableHolder: @unchecked Sendable {
    public let value: Any

    public init(value: Any) {
        self.value = value
    }
}
