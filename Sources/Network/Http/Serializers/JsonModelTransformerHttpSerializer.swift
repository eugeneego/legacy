//
// JsonModelTransformerHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct JsonModelTransformerHttpSerializer<T: Transformer>: HttpSerializer {
    public typealias Value = T.T

    public let contentType = "application/json"

    public let transformer: T

    public init(transformer: T) {
        self.transformer = transformer
    }

    public func serialize(value: Value?) -> NSData? {
        return transformer.toAny(value).flatMap { try? NSJSONSerialization.dataWithJSONObject($0, options: []) }
    }

    public func deserialize(data: NSData?) -> Value? {
        return transformer.fromAny(data.flatMap { try? NSJSONSerialization.JSONObjectWithData($0, options: .AllowFragments) })
    }
}
