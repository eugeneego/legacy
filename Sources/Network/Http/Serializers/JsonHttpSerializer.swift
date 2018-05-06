//
// JsonHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct JsonHttpSerializer: HttpSerializer {
    public typealias Value = Any

    public let contentType = "application/json"

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .failure(HttpSerializationError.noData) }

        return Result {
            try JSONSerialization.data(withJSONObject: value, options: [])
        }
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data else { return .failure(HttpSerializationError.noData) }

        return Result {
            try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
    }
}
