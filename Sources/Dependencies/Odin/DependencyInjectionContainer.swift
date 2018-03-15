//
// DependencyInjectionContainer
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol DependencyInjectionContainer {
    func resolve(_ object: Any?)
    func resolve<D>() -> D?
}

public extension DependencyInjectionContainer {
    public func resolveOrDie<D>() -> D {
        guard let result: D = resolve() else { fatalError("Couldn't resolve dependency \(D.self)") }
        return result
    }
}
