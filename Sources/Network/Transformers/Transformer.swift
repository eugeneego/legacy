//
// Transformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public protocol Transformer {
    associatedtype T

    func fromAny(_ value: Any?) -> T?

    func toAny(_ value: T?) -> Any?
}
