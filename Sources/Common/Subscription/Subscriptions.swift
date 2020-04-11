//
// Subscriptions
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public class Subscriptions<Value> {
    public typealias Listener = (Value) -> Void

    private var subscriptions: [String: Listener] = [:] {
        didSet {
            onChange?()
        }
    }

    public var onChange: (() -> Void)?

    public var isEmpty: Bool {
        subscriptions.isEmpty
    }

    public var count: Int {
        subscriptions.count
    }

    public var copy: Subscriptions<Value> {
        let copy = Subscriptions<Value>()
        copy.subscriptions = subscriptions
        copy.onChange = onChange
        return copy
    }

    public init(onChange: (() -> Void)? = nil) {
        self.onChange = onChange
    }

    public func add(_ listener: @escaping Listener) -> Subscription {
        let id = UUID().uuidString
        let subscription = SimpleSubscription { [weak self] in
            self?.subscriptions[id] = nil
        }
        subscriptions[id] = listener
        return subscription
    }

    public func fire(_ value: Value) {
        subscriptions.values.forEach { $0(value) }
    }
}
