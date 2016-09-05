//
// DataHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DataHttpSerializer: HttpSerializer {
    public typealias Value = Data

    public let contentType: String

    public init(contentType: String) {
        self.contentType = contentType
    }

    public func serialize(_ value: Value?) -> Data? {
        return value
    }

    public func deserialize(_ data: Data?) -> Value? {
        return data
    }
}
