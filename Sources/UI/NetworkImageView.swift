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

        if !loading && image == nil {
            update()
        }
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    private lazy var task: Task<Void, Never>? = nil
    private var imageLoaderTask: ImageLoaderTask?

    private var loading: Bool {
        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
            return task != nil
        } else {
            return imageLoaderTask != nil
        }
    }

    private func update() {
        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
            task?.cancel()
            task = nil
        } else {
            imageLoaderTask?.cancel()
            imageLoaderTask = nil
        }

        image = placeholder

        guard bounds.width > 0.1 && bounds.height > 0.1 else { return }
        guard let imageLoader = imageLoader, let imageUrl = imageUrl else { return }

        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *) {
            task = Task {
                let result = await imageLoader.load(url: imageUrl, size: frame.size, mode: resizeMode)
                task = nil
                guard let image = result.value?.1 else { return }

                addFadeTransition()
                self.image = image
            }
        } else {
            imageLoaderTask = imageLoader.load(url: imageUrl, size: frame.size, mode: resizeMode) { [weak self] result in
                self?.imageLoaderTask = nil
                guard let self = self, imageUrl == self.imageUrl, let image = result.value?.1 else { return }

                self.addFadeTransition()
                self.image = image
            }
        }
    }
}

#endif
