//
// DecimalLightTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct DecimalLightTransformer: LightTransformer {
    public typealias T = Decimal

    public init() {}

    public func from(any value: Any?) -> T? {
        return (value as? NSNumber).flatMap { Decimal(string: "\($0)", locale: Locale(identifier: "en_US")) }
    }

    public func to(any value: T?) -> Any? {
        return value.map { NSDecimalNumber(decimal: $0) }
    }
}
