//
// ShadowView
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public class ShadowView: UIView {
    @IBInspectable public var shadowColor: UIColor = .blackColor() {
        didSet {
            layer.shadowColor = shadowColor.CGColor
        }
    }

    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 3, height: 3) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable public var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable public var shadowRadius: CGFloat = 5 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable public var shadowCornerRadius: CGFloat = 0 {
        didSet {
            updatePath()
        }
    }

    public var shadowPath: UIBezierPath? {
        didSet {
            updatePath()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        updatePath()
    }

    private func updatePath() {
        let path = shadowPath ?? UIBezierPath(roundedRect: bounds, cornerRadius: shadowCornerRadius)
        layer.shadowPath = path.CGPath
    }
}
