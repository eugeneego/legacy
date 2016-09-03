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
public class Odin: DependencyInjectionContainer {
    public typealias Resolver = Any -> Void

    private var resolvers: [Resolver] = []

    public func register(resolver: Resolver) {
        resolvers.append(resolver)
    }

    public func register<D>(resolver: (inout D) -> Void) {
        register { object in
            guard var object = object as? D else { return }

            resolver(&object)
        }
    }

    public func resolve(object: Any) {
        resolvers.forEach { resolver in
            resolver(object)
        }
    }
}
