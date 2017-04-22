//
// JsonModelTransformerHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct JsonModelTransformerHttpSerializer<T: SimpleTransformer>: HttpSerializer {
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
