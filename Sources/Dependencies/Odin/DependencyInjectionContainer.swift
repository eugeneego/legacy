//
// DependencyInjectionContainer
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol DependencyInjectionContainer {
    /// Resolves dependencies of an object.
    /// - parameter object: an object to resolve protocols.
    /// - note:
    ///
    ///       container.resolve(object)
    func resolve(_ object: Any?)

    /// Resolves a registered type.
    /// - returns: a registered object for a given type.
    /// - note:
    ///
    ///       let dependency: Dependency? = container.resolve()
    func resolve<D>() -> D?
}

public extension DependencyInjectionContainer {
    /// Resolves a registered type or crashes.
    /// - returns: a registered object for a given type.
    /// - note: In Swift 4 it creates a compilation error "ambiguous use of 'resolveOrDie()'".
    /// Use a non optional variant of this method.
    ///
    ///       var dependency: Dependency?
    ///       dependency = container.resolveOrDie() as Dependency
    func resolveOrDie<D>() -> D? {
        guard let result: D = resolve() else { fatalError("Couldn't resolve dependency \(D.self)") }
        return result
    }

    /// Resolves a registered type or crashes.
    /// - returns: a registered object for a given type.
    /// - note: If you use it with optional type, Swift 4 compiler fails with an error "ambiguous use of 'resolveOrDie()'".
    /// Use a non optional type parameter in that case as in example below.
    ///
    ///       // non optional type
    ///       let dependency: Dependency = container.resolveOrDie()
    ///
    ///       // optional type
    ///       var dependency: Dependency?
    ///       dependency = container.resolveOrDie() as Dependency
    func resolveOrDie<D>() -> D {
        guard let result: D = resolve() else { fatalError("Couldn't resolve dependency \(D.self)") }
        return result
    }
}
