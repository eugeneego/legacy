//
// ColorLightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct ColorLightTransformer: LightTransformer {
    public typealias T = EEColor

    public init() {}

    public func from(any value: Any?) -> T? {
        (value as? String).flatMap(T.from(hex:))
    }

    public func to(any value: T?) -> Any? {
        value?.hexARGB
    }
}
