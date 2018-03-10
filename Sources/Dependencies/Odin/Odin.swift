//
// Odin
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

/// Simple dependency injection container
public class Odin: DependencyInjectionContainer {
    public typealias ProtocolResolver = (Any) -> Void
    public typealias TypeResolver = () -> Any

    private let parentContainer: DependencyInjectionContainer?

    private var protocolResolvers: [ProtocolResolver] = []
    private var typeResolvers: [String: TypeResolver] = [:]

    public init(parentContainer: DependencyInjectionContainer? = nil) {
        self.parentContainer = parentContainer
    }

    private func register(_ resolver: @escaping ProtocolResolver) {
        protocolResolvers.append(resolver)
    }

    public func register<D>(_ resolver: @escaping (inout D) -> Void) {
        register { object in
            guard var object = object as? D else { return }

            resolver(&object)
        }
    }

    public func resolve(_ object: Any?) {
        guard let object = object else { return }

        parentContainer?.resolve(object)

        protocolResolvers.forEach { resolver in
            resolver(object)
        }
    }

    private func key<D>(_ type: D.Type) -> String {
        return String(reflecting: type)
    }

    public func register<D>(_ resolver: @escaping () -> D) {
        typeResolvers[key(D.self)] = resolver
    }

    public func resolve<D>() -> D? {
        return typeResolvers[key(D.self)]?() as? D ?? parentContainer?.resolve()
    }
}
