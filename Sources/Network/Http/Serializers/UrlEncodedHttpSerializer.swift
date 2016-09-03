//
// UrlEncodedHttpSerializer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct UrlEncodedHttpSerializer: HttpSerializer {
    public typealias Value = [String: String]

    public let contentType = "application/x-www-form-urlencoded"

    public func serialize(value: Value?) -> NSData? {
        return serialize(value).flatMap { $0.dataUsingEncoding(NSUTF8StringEncoding) }
    }

    public func deserialize(data: NSData?) -> Value? {
        return deserialize(data.flatMap { String(data: $0, encoding: NSUTF8StringEncoding) })
    }

    public func serialize(value: Value?) -> String? {
        guard let value = value else { return nil }

        let result = value
            .map { name, value in
                UrlEncodedHttpSerializer.encode(name) + "=" + UrlEncodedHttpSerializer.encode("\(value)")
            }
            .joinWithSeparator("&")
        return result
    }

    public func deserialize(string: String?) -> Value? {
        guard let string = string else { return nil }

        var params: Value = [:]
        let cmp = string.componentsSeparatedByString("&")
        cmp.forEach { param in
            let parts = param.componentsSeparatedByString("=")
            if parts.count == 2 {
                let name = UrlEncodedHttpSerializer.decode(parts[0])
                let value = UrlEncodedHttpSerializer.decode(parts[1])
                params[name] = value
            }
        }
        return params
    }

    public static func encode(string: String) -> String {
        let charset = NSMutableCharacterSet.alphanumericCharacterSet()
        charset.addCharactersInString("-_.")
        return string.stringByAddingPercentEncodingWithAllowedCharacters(charset) ?? ""
    }

    public static func decode(string: String) -> String {
        return string.stringByRemovingPercentEncoding ?? ""
    }
}
