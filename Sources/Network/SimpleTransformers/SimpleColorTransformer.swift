//
// SimpleColorTransformer
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

public struct SimpleColorTransformer: SimpleTransformer {
    public typealias T = EEColor

    public func from(any value: Any?) -> T? {
        return (value as? String).flatMap(T.from(hex:))
    }

    public func to(any value: T?) -> Any? {
        return value?.hexARGB
    }
}
