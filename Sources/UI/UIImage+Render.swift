//
// UIImage (Render)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit) && !os(watchOS)

import UIKit

public extension UIImage {
    typealias Render = (_ rendererContext: UIGraphicsImageRendererContext, _ bounds: CGRect) -> Void

    static func image(size: CGSize, render: Render) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            render(context, renderer.format.bounds)
        }
    }

    func prerender() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0)
        draw(at: .zero)
        UIGraphicsEndImageContext()
    }

    func prerenderedImage() -> UIImage {
        Self.image(size: size) { _, bounds in
            draw(in: bounds)
        }
    }

    static func image(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        image(size: size) { context, bounds in
            color.setFill()
            context.fill(bounds)
        }
    }
}

#endif