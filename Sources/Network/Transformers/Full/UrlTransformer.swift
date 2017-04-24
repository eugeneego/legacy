//
// UrlTransformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public struct UrlTransformer<From>: FullTransformer {
    public typealias Source = From
    public typealias Destination = URL

    public init() {}

    public func convert(source value: Source) -> TransformerResult<Destination> {
        return TransformerResult((value as? String).flatMap(URL.init), .transform)
    }

    public func convert(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult(value.absoluteString as? From, .transform)
    }
}
