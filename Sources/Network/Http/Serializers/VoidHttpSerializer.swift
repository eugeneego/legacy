//
// VoidHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct VoidHttpSerializer: HttpSerializer {
    public typealias Value = Any

    public let contentType = "application/json"

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        return .success(Data())
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        return .success(())
    }
}
