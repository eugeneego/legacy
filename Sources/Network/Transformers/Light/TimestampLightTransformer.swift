//
// TimestampLightTransformer
// EEUtilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct TimestampLightTransformer: LightTransformer {
    public typealias T = Date

    public func from(any value: Any?) -> T? {
        return NumberLightTransformer<Int64>().from(any: value).map { Date.init(timeIntervalSince1970: TimeInterval($0)) }
    }

    public func to(any value: T?) -> Any? {
        return value.flatMap { NumberLightTransformer<Int64>().to(any: Int64($0.timeIntervalSince1970)) }
    }
}
