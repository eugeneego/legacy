//
// LightTransformer
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol LightTransformer: Sendable {
    associatedtype T: Sendable

    func from(any value: Any?) -> T?

    func to(any value: T?) -> Any?
}
