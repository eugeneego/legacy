//
// UrlTransformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public struct UrlTransformer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = URL

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        TransformerResult((value as? String).flatMap(URL.init), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        TransformerResult(value.absoluteString as? From, .transform)
    }
}
