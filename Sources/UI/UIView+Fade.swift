//
// UIView (Fade)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

public extension UIView {
    func addFadeTransition(timing: CAMediaTimingFunctionName = .easeInEaseOut) {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: timing)
        transition.type = .fade
        layer.add(transition, forKey: "fadeTransition")
    }
}

#endif

#endif
