//
// Odin
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

/// Simple dependency injection container.
public class Odin: DependencyInjectionContainer {
    public typealias ProtocolResolver = (Any) -> Void
    public typealias TypeResolver = () -> Any

    private let parentContainer: DependencyInjectionContainer?

    private var protocolResolvers: [ProtocolResolver] = []
    private var typeResolvers: [String: TypeResolver] = [:]

    /// Initializes a container with an optional parent container.
    /// - parameter parentContainer: an optional parent container.
    public init(parentContainer: DependencyInjectionContainer? = nil) {
        self.parentContainer = parentContainer
    }

    private func register(_ resolver: @escaping ProtocolResolver) {
        protocolResolvers.append(resolver)
    }

    /// Registers a protocol resolver.
    /// - parameter resolver: a function that fills an object if it conforms the protocol.
    /// - note:
    ///
    ///       protocol SomeDependency {
    ///           var dependency: Dependency! { get set }
    ///       }
    ///
    ///       let dependency = MyDependency()
    ///       let container = Odin()
    ///       container.register { (object: inout SomeDependency) in
    ///           object.dependency = dependency
    ///       }
    public func register<D>(_ resolver: @escaping (inout D) -> Void) {
        register { object in
            guard var object = object as? D else { return }

            resolver(&object)
        }
    }

    /// Resolves an object with registered protocol resolvers.
    /// The implementation checks conformance of an object to all registered protocols
    /// and run resolvers for appropriate ones.
    /// It resolves using a parent container if present, then using its own registered resolvers.
    /// - parameter object: an object to resolve protocols.
    /// - note:
    ///
    ///       container.resolve(object)
    public func resolve(_ object: Any?) {
        guard let object = object else { return }

        parentContainer?.resolve(object)

        protocolResolvers.forEach { resolver in
            resolver(object)
        }
    }

    /// Returns a string representation of a type.
    /// - parameter type: an object type.
    /// - returns: a string representation of a type. For example, `Module.Type.NestedType`.
    private func key<D>(_ type: D.Type) -> String {
        String(reflecting: type)
    }

    /// Registers a type resolver.
    /// - parameter resolver: a function that returns an object of type D.
    /// - note:
    ///
    ///       let dependency: Dependency = MyDependency()
    ///       let container = Odin()
    ///       container.register { () -> Dependency in
    ///           return dependency
    ///       }
    public func register<D>(_ resolver: @escaping () -> D) {
        typeResolvers[key(D.self)] = resolver
    }

    /// Resolves a registered type.
    /// Checks and run a resolver for a given type.
    /// - returns: a registered object for a given type.
    /// - note:
    ///
    ///       let dependency: Dependency? = container.resolve()
    public func resolve<D>() -> D? {
        typeResolvers[key(D.self)]?() as? D ?? parentContainer?.resolve()
    }
}
