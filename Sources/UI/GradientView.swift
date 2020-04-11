//
// GradientView
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

open class GradientView: UIView {
    @IBInspectable open var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @IBInspectable open var endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0)

    @IBInspectable open var startColor: UIColor = .white
    @IBInspectable open var endColor: UIColor = .lightGray

    open var locations: [NSNumber]?
    open var colors: [UIColor]?

    open override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        update()
    }

    open func update() {
        guard let layer = self.layer as? CAGradientLayer else { return }

        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.locations = locations

        let colors = self.colors ?? []
        if !colors.isEmpty {
            layer.colors = colors.map { $0.cgColor }
        } else {
            layer.colors = [ startColor.cgColor, endColor.cgColor ]
        }
    }
}

#endif

#endif
