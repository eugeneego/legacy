//
// ColorTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public struct ColorTransformer: Transformer {
    public typealias T = EEColor

    public func fromAny(_ value: Any?) -> T? {
        return (value as? String).flatMap(T.from(hex:))
    }

    public func toAny(_ value: T?) -> Any? {
        return value?.hexARGB
    }
}
