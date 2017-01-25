//
// UIImage (Color)
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public extension UIImage {
    public static func from(
        color: UIColor, size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false, scale: CGFloat = 0
    ) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
