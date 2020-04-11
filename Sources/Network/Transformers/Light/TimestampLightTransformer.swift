//
// TimestampLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct TimestampLightTransformer: LightTransformer {
    public typealias T = Date

    private let numberTransformer: NumberLightTransformer = NumberLightTransformer<Int64>()
    private let scale: TimeInterval

    public init(scale: TimeInterval = 1) {
        self.scale = scale
    }

    public func from(any value: Any?) -> T? {
        numberTransformer.from(any: value).map { Date(timeIntervalSince1970: TimeInterval($0) * scale) }
    }

    public func to(any value: T?) -> Any? {
        value.flatMap { numberTransformer.to(any: Int64($0.timeIntervalSince1970 / scale)) }
    }
}
