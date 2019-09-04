//
// ShadowView
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

open class ShadowView: UIView {
    @IBInspectable open var shadowColor: UIColor = .black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable open var shadowOffset: CGSize = CGSize(width: 3, height: 3) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable open var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable open var shadowRadius: CGFloat = 5 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable open var shadowCornerRadius: CGFloat = 0 {
        didSet {
            updatePath()
        }
    }

    open var shadowPath: UIBezierPath? {
        didSet {
            updatePath()
        }
    }

    public override required init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        updatePath()
    }

    private func updatePath() {
        let path = shadowPath ?? UIBezierPath(roundedRect: bounds, cornerRadius: shadowCornerRadius)
        layer.shadowPath = path.cgPath
    }
}

#endif

#endif
