//
// GradientView
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public class GradientView: UIView {
    @IBInspectable public var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    @IBInspectable public var endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0)

    @IBInspectable public var startColor: UIColor = .whiteColor()
    @IBInspectable public var endColor: UIColor = .lightGrayColor()

    @IBInspectable public var locations: [NSNumber]?
    @IBInspectable public var colors: [UIColor]?

    public override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        update()
    }

    public func update() {
        let layer = self.layer as! CAGradientLayer
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.locations = locations

        let colors = self.colors ?? []
        if !colors.isEmpty {
            layer.colors = colors.map { $0.CGColor }
        } else {
            layer.colors = [ startColor.CGColor, endColor.CGColor ]
        }
    }
}
