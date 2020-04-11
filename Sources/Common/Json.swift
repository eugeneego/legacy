//
// JSON
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct Json {
    public let value: Any?

    public init(value: Any?) {
        self.value = value
    }

    public init(data: Data?) {
        value = data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) }
    }

    public init(string: String?) {
        self.init(data: string?.data(using: .utf8))
    }

    public init(url: URL?) {
        self.init(data: url.flatMap { try? Data(contentsOf: $0) })
    }

    public var dictionary: [String: Any]? {
        value as? [String: Any]
    }

    public var array: [Any]? {
        value as? [Any]
    }

    public var data: Data? {
        value.flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
    }

    public var string: String? {
        data.flatMap { String(data: $0, encoding: .utf8) }
    }
}
