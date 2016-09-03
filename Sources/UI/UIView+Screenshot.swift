//
// UIView (Screenshot)
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public extension UIView {
    public func screenshot(afterUpdate afterUpdate: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: afterUpdate)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
