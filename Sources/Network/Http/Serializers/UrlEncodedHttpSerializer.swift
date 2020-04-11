//
// UrlEncodedHttpSerializer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct UrlEncodedHttpSerializer: HttpSerializer {
    public typealias Value = [String: String]

    public let contentType: String = "application/x-www-form-urlencoded"

    public init() {}

    public func serialize(_ value: Value?) -> Result<Data, HttpSerializationError> {
        guard let value = value else { return .success(Data()) }

        let data = serialize(value).data(using: String.Encoding.utf8)
        return Result(data, HttpSerializationError.noData)
    }

    public func deserialize(_ data: Data?) -> Result<Value, HttpSerializationError> {
        guard let data = data, !data.isEmpty else { return .success([:]) }

        let value = String(data: data, encoding: String.Encoding.utf8).map(deserialize)
        return Result(value, HttpSerializationError.noData)
    }

    public func serialize(_ value: Value) -> String {
        let result = value
            .map { name, value in
                UrlEncodedHttpSerializer.encode(name) + "=" + UrlEncodedHttpSerializer.encode("\(value)")
            }
            .joined(separator: "&")
        return result
    }

    public func deserialize(_ string: String) -> Value {
        var params: Value = [:]
        let cmp = string.components(separatedBy: "&")
        cmp.forEach { param in
            let parts = param.components(separatedBy: "=")
            if parts.count == 2 {
                let name = UrlEncodedHttpSerializer.decode(parts[0])
                let value = UrlEncodedHttpSerializer.decode(parts[1])
                params[name] = value
            }
        }
        return params
    }

    private static var characters: CharacterSet = {
        var characters = CharacterSet.alphanumerics
        characters.insert(charactersIn: "-_.")
        return characters
    }()

    public static func encode(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: characters) ?? ""
    }

    public static func decode(_ string: String) -> String {
        string.removingPercentEncoding ?? ""
    }
}
