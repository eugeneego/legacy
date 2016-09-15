//
// JsonHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct JsonHttpSerializer: HttpSerializer {
    public typealias Value = Any

    public let contentType = "application/json"

    public func serialize(_ value: Value?) -> Data? {
        return value.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
    }

    public func deserialize(_ data: Data?) -> Value? {
        return data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) }
    }
}
