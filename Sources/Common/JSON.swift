//
// JSON
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

open class JSON {
    open let value: Any?

    public init(value: Any?) {
        self.value = value
    }

    public init(data: Data?) {
        value = data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) }
    }

    public convenience init(string: String?) {
        self.init(data: string?.data(using: String.Encoding.utf8))
    }

    public convenience init(url: URL?) {
        self.init(data: url.flatMap { try? Data(contentsOf: $0) })
    }

    open var dictionary: [String: Any]? {
        return value as? [String: Any]
    }

    open var array: [Any]? {
        return value as? [Any]
    }

    open var data: Data? {
        return value.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
    }
}
