//
// UIView (Screenshot)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit) && !os(watchOS)

import UIKit

public extension UIView {
    func screenshot(afterUpdate: Bool = false) -> UIImage {
        UIImage.image(size: bounds.size) { _, bounds in
            drawHierarchy(in: bounds, afterScreenUpdates: afterUpdate)
        }
    }
}

#endif
