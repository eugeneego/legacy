//
// GalleryImageViewController
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class GalleryImageViewController: GalleryItemViewController, UIScrollViewDelegate {
    public let image: GalleryMedia.Image
    private var fullImage: UIImage?

    open var maximumZoomScale: CGFloat = 2
    open var exitScaleEnabled: Bool = false
    open var hideControlsOnDrag: Bool = false
    open var hideControlsOnZoom: Bool = false

    private var isShown: Bool = false
    private var isLaidOut: Bool = false

    private var scrollSize: CGSize = .zero
    private var lastScale: CGFloat = 1.0
    private var exitScale: CGFloat = 0.0
    private var lastFrame: CGRect?

    public let scrollView: UIScrollView = UIScrollView()
    public let imageView: UIImageView = UIImageView()

    public init(image: GalleryMedia.Image) {
        self.image = image
        fullImage = image.fullImage

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Scroll View

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.canCancelContentTouches = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(scrollView)

        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        scrollView.addSubview(imageView)

        // Constraints

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // Image Loading

        imageView.image = fullImage ?? image.previewImage
        mediaSize = imageView.image?.size ?? .zero

        // Controls

        setupTransition()
        setupCommonControls()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isShown {
            isShown = true
            load()
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isTransitioning = false
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLaidOut {
            isLaidOut = true
            scrollSize = scrollView.frame.size
            setupScrollView(with: scrollSize)
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard !isTransitioning else { return }

        scrollSize = size

        coordinator.animate(
            alongsideTransition: { _ in
                self.setupScrollView(with: size)
            },
            completion: nil
        )
    }

    // MARK: - Controls

    open override var isShareAvailable: Bool {
        return fullImage != nil
    }

    open override func shareTap() {
        guard let image = fullImage else { return }

        let controller = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Image

    private func load() {
        guard let fullImageLoader = image.fullImageLoader, fullImage == nil else { return }

        loadingIndicatorView.startAnimating()

        fullImageLoader { [weak self] result in
            guard let `self` = self else { return }

            self.loadingIndicatorView.stopAnimating()

            if let image = result.value {
                self.fullImage = image
                self.imageView.addFadeTransition()
                self.imageView.image = image

                let size = image.size
                let equal = abs(self.mediaSize.width - size.width) < 0.1 && abs(self.mediaSize.height - size.height) < 0.1
                if !equal {
                    self.mediaSize = size
                    self.scrollSize = self.scrollView.frame.size
                    self.setupScrollView(with: self.scrollSize)
                }
            }

            self.updateControls()
        }
    }

    private func setupScrollView(with size: CGSize) {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        imageView.frame = CGRect(origin: .zero, size: mediaSize)

        calcZoom(with: size)
        zoomAll()

        scrollViewDidZoom(scrollView)
    }

    private func calcZoom(with size: CGSize) {
        let contentSize = mediaSize
        var minimumScale: CGFloat = 1
        var maximumScale: CGFloat = 1

        if mediaSize.width > 0.1 && mediaSize.height > 0.1 {
            let xScale = size.width / contentSize.width
            let yScale = size.height / contentSize.height
            minimumScale = min(xScale, yScale)
            maximumScale = max(maximumZoomScale, minimumScale)
        }

        scrollView.contentSize = contentSize
        scrollView.minimumZoomScale = minimumScale
        scrollView.maximumZoomScale = maximumScale

        exitScale = minimumScale * 0.64
    }

    private func zoomAll() {
        lastScale = scrollView.minimumZoomScale
        scrollView.zoomScale = scrollView.minimumZoomScale
    }

    // MARK: - Scroll View

    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let contentSize = scrollView.contentSize
        guard contentSize != .zero else { return }

        let x = (contentSize.width < scrollSize.width) ? (scrollSize.width - contentSize.width) * 0.5 : 0.0
        let y = (contentSize.height < scrollSize.height) ? (scrollSize.height - contentSize.height) * 0.5 : 0.0
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)

        if scrollView.isZooming {
            lastScale = scrollView.zoomScale
            lastFrame = imageView.convert(imageView.bounds, to: view)
        } else if !isTransitioning && exitScaleEnabled && lastScale < exitScale {
            isTransitioning = true

            DispatchQueue.main.async {
                self.closeTap()
            }
        }

        if !isTransitioning {
            let enabled = abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 0.001
            transition.panGestureRecognizer.isEnabled = enabled && isTransitionEnabled
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if hideControlsOnDrag {
            showControls(false, animated: true)
        }
    }

    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if hideControlsOnZoom {
            showControls(false, animated: true)
        }
    }

    // MARK: - Transition

    open override func zoomTransitionPrepareAnimatingView(_ animatingImageView: UIImageView) {
        super.zoomTransitionPrepareAnimatingView(animatingImageView)

        animatingImageView.image = imageView.image
        animatingImageView.frame = lastFrame ?? imageView.convert(imageView.bounds, to: view)
    }

    open override func zoomTransitionOnStart() {
        super.zoomTransitionOnStart()

        lastFrame = nil
    }

    open override func zoomTransitionHideViews(hide: Bool) {
        super.zoomTransitionHideViews(hide: hide)

        imageView.isHidden = hide
    }
}
