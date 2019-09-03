//
// UIImage (Color)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

import UIKit

public extension UIImage {
    static func from(
        color: UIColor, size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false, scale: CGFloat = 0
    ) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Cannot create image from color \(color)")
        }
        UIGraphicsEndImageContext()
        return image
    }
}

#endif
