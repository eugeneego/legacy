//
// ColorTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

public struct ColorTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = EEColor

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        return TransformerResult((value as? String).flatMap(EEColor.from(hex:)), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(value.hexARGB as? From, .transform)
    }
}
