//
// DateTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DateTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = Date

    private let formatter: DateFormatter

    public init(format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ", locale: Locale = Locale(identifier: "en_US_POSIX")) {
        formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = format
    }

    public func convert(source value: Source) -> TransformerResult<Destination> {
        return TransformerResult((value as? String).flatMap(formatter.date(from:)), .transform)
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(formatter.string(from: value) as? From, .transform)
    }
}
