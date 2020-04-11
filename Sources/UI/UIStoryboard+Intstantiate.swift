//
// UIStoryboard (Instantiate)
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

public extension UIStoryboard {
    func instantiateInitial<T: UIViewController>() -> T {
        guard let controller = instantiateInitialViewController() else {
            fatalError("Cannot instantiate initial view controller.")
        }

        guard let typedController = controller as? T else {
            fatalError("Cannot instantiate initial view controller. Expected type \(T.self), but received \(type(of: controller))")
        }

        return typedController
    }

    func instantiate<T: UIViewController>() -> T {
        instantiate(id: String(describing: T.self))
    }

    func instantiate<T: UIViewController>(id: String) -> T {
        let controller = instantiateViewController(withIdentifier: id)

        guard let typedController = controller as? T else {
            fatalError("Cannot instantiate view controller with id \(id). Expected type \(T.self), but received \(type(of: controller))")
        }

        return typedController
    }
}

#endif

#endif
