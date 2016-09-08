//
// Odin
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

/**
 Simple dependency injection container
*/
open class Odin: DependencyInjectionContainer {
    public typealias Resolver = (Any) -> Void

    private var resolvers: [Resolver] = []

    open func register(_ resolver: @escaping Resolver) {
        resolvers.append(resolver)
    }

    open func register<D>(_ resolver: @escaping (inout D) -> Void) {
        register { object in
            guard var object = object as? D else { return }

            resolver(&object)
        }
    }

    open func resolve(_ object: Any) {
        resolvers.forEach { resolver in
            resolver(object)
        }
    }
}
