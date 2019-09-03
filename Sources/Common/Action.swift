//
// Action
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

@objc public protocol Action {
    func perform()
}

public final class BlockAction: Action {
    public let action: () -> Void

    public func perform() {
        action()
    }

    public init(action: @escaping () -> Void) {
        self.action = action
    }
}

public final class TargetAction<Target: AnyObject>: Action {
    public private(set) weak var target: Target?
    public let action: (Target) -> () -> Void

    public func perform() {
        if let target = target {
            action(target)()
        }
    }

    public init(target: Target, action: @escaping (Target) -> () -> Void) {
        self.target = target
        self.action = action
    }
}

public final class TargetSenderAction<Target: AnyObject, Sender: AnyObject>: Action {
    public private(set) weak var target: Target?
    public private(set) weak var sender: Sender?
    public let action: (Target) -> (Sender) -> Void

    public func perform() {
        if let target = target, let sender = sender {
            action(target)(sender)
        }
    }

    public init(target: Target, sender: Sender, action: @escaping (Target) -> (Sender) -> Void) {
        self.target = target
        self.sender = sender
        self.action = action
    }
}
