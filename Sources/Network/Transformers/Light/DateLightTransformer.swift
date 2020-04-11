//
// DateLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct DateLightTransformer: LightTransformer {
    public typealias T = Date

    private let formatter: DateFormatter

    public init(format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ", locale: Locale = Locale(identifier: "en_US_POSIX")) {
        formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = format
    }

    public func from(any value: Any?) -> T? {
        (value as? String).flatMap(formatter.date(from:))
    }

    public func to(any value: T?) -> Any? {
        value.flatMap(formatter.string(from:))
    }
}
