//
// DataHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct DataHttpSerializer: HttpSerializer {
    public typealias Value = Data

    public let contentType: String

    public init(contentType: String) {
        self.contentType = contentType
    }

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        .success(value ?? Data())
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        .success(data ?? Data())
    }
}
