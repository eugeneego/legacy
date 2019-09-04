//
// UIView (Screenshot)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

public extension UIView {
    func screenshot(afterUpdate: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: afterUpdate)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Cannot get image from context for screenshot.")
        }
        UIGraphicsEndImageContext()
        return image
    }
}

#endif

#endif
