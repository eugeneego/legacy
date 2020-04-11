//
// UIView (Nib)
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

public extension UIView {
    private static func loadNib<T: UIView>(
        name: String,
        bundle: Bundle,
        owner: Any?,
        options: [UINib.OptionsKey: Any]?
    ) -> T {
        guard let nibContent = bundle.loadNibNamed(name, owner: owner, options: options) else {
            fatalError("Cannot load nib with name \(name).")
        }

        guard let firstObject = nibContent.first else {
            fatalError("Cannot get first object from \(name) nib.")
        }

        guard let view = firstObject as? T else {
            fatalError("Invalid \(name) nib view type. Expected \(T.self), but received \(type(of: firstObject))")
        }

        return view
    }

    class func fromNib(
        name: String? = nil,
        bundle: Bundle? = nil,
        owner: Any? = nil,
        options: [UINib.OptionsKey: Any]? = nil
    ) -> Self {
        loadNib(name: name ?? String(describing: self), bundle: bundle ?? Bundle(for: self), owner: owner, options: options)
    }
}

#endif

#endif
