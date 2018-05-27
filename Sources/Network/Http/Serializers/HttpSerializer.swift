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
}
