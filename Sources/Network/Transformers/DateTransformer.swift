//
// DateTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DateTransformer: Transformer {
    public typealias T = NSDate

    private let formatter: NSDateFormatter

    public init(format: String) {
        formatter = NSDateFormatter()
        formatter.dateFormat = format
    }

    public func fromAny(value: AnyObject?) -> T? {
        return (value as? String).flatMap(formatter.dateFromString)
    }

    public func toAny(value: T?) -> AnyObject? {
        return value.flatMap(formatter.stringFromDate)
    }
}
