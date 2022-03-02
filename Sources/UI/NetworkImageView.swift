//
// GradientView
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit) && !os(watchOS)

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

        if task == nil && image == nil {
            update()
        }
    }

    private var task: Task<Void, Never>?

    private func update() {
        task?.cancel()
        task = nil

        image = placeholder

        guard bounds.width > 0.1 && bounds.height > 0.1 else { return }
        guard let imageLoader = imageLoader, let imageUrl = imageUrl else { return }

        task = Task {
            let result = await imageLoader.load(url: imageUrl, size: frame.size, mode: resizeMode)
            task = nil
            guard let image = result.value?.1 else { return }

            addFadeTransition()
            self.image = image
        }
    }
}

#endif
