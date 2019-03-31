//
// Subscriptions
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

open class Subscriptions<Value> {
    public typealias Listener = (Value) -> Void

    private var subscriptions: [String: Listener] = [:]

    open var copy: Subscriptions<Value> {
        let copy = Subscriptions<Value>()
        copy.subscriptions = subscriptions
        return copy
    }

    public init() {
    }

    open func add(_ listener: @escaping Listener) -> Subscription {
        let id = UUID().uuidString
        let subscription = SimpleSubscription { [weak self] in
            self?.subscriptions[id] = nil
        }
        subscriptions[id] = listener
        return subscription
    }

    open func fire(_ value: Value) {
        subscriptions.values.forEach { $0(value) }
    }
}
