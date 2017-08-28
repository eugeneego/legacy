//
// UIStoryboard (Instantiate)
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public extension UIStoryboard {
    public func instantiateInitial<T: UIViewController>() -> T {
        guard let controller = instantiateInitialViewController() else {
            fatalError("Cannot instantiate initial view controller.")
        }

        guard let typedController = controller as? T else {
            fatalError("Cannot instantiate initial view controller. Expected type \(T.self), but received \(type(of: controller))")
        }

        return typedController
    }

    public func instantiate<T: UIViewController>() -> T {
        return instantiate(id: String(describing: T.self))
    }

    public func instantiate<T: UIViewController>(id: String) -> T {
        let controller = instantiateViewController(withIdentifier: id)

        guard let typedController = controller as? T else {
            fatalError("Cannot instantiate view controller with id \(id). Expected type \(T.self), but received \(type(of: controller))")
        }

        return typedController
    }
}
