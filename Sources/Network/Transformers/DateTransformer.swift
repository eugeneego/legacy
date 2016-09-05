//
// DateTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DateTransformer: Transformer {
    public typealias T = Date

    private let formatter: DateFormatter

    public init(format: String) {
        formatter = DateFormatter()
        formatter.dateFormat = format
    }

    public func fromAny(_ value: Any?) -> T? {
        return (value as? String).flatMap(formatter.date(from:))
    }

    public func toAny(_ value: T?) -> Any? {
        return value.flatMap(formatter.string(from:))
    }
}
