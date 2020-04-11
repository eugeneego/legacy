//
// DecimalLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct DecimalLightTransformer: LightTransformer {
    public typealias T = Decimal

    public init() {}

    public func from(any value: Any?) -> T? {
        (value as? NSNumber).flatMap { Decimal(string: "\($0)", locale: Locale(identifier: "en_US")) }
    }

    public func to(any value: T?) -> Any? {
        value.map { NSDecimalNumber(decimal: $0) }
    }
}
