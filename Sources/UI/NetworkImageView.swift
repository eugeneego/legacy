//
// GradientView
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

open class NetworkImageView: UIImageView {
    open var imageLoader: ImageLoader?
    open var resizeMode: ResizeMode = .fill
    open var placeholder: UIImage?

    open var imageUrl: URL? {
        didSet {
            if oldValue != imageUrl {
                update()
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !loading && image == nil {
            update()
        }
    }

    private var loading: Bool = false

    private func update() {
        image = placeholder

        guard bounds.width > 0.1 && bounds.height > 0.1 else { return }
        guard let imageLoader = imageLoader, let imageUrl = imageUrl else { return }

        loading = true

        imageLoader.load(url: imageUrl, size: frame.size, mode: resizeMode) { [weak self] result in
            guard let `self` = self, imageUrl == self.imageUrl else { return }

            self.loading = false
            guard let image = result.value?.1 else { return }

            self.addFadeTransition()
            self.image = image
        }
    }
}

#endif

#endif
