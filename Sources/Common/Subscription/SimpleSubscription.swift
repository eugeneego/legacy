//
// SimpleSubscription
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public class SimpleSubscription: Subscription {
    private let unsubscribeClosure: () -> Void

    public init(unsubscribeClosure: () -> Void) {
        self.unsubscribeClosure = unsubscribeClosure
    }

    deinit {
        unsubscribe()
    }

    public func unsubscribe() {
        unsubscribeClosure()
    }
}
