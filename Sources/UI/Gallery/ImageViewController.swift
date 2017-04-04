//
// ImageViewController
// EE Gallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate, ZoomTransitionDelegate {
    private let titleView: UIView = UIView()
    private let closeButton: UIButton = UIButton(type: .custom)
    private let shareButton: UIButton = UIButton(type: .custom)
    private let scrollView: UIScrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()
    private let animatingImageView: UIImageView = UIImageView()
    private let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    private let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

    var image: GalleryMedia.Image = GalleryMedia.Image()

    var closeAction: (() -> Void)?
    var presenterInterfaceOrientations: (() -> UIInterfaceOrientationMask?)?

    var closeTitle: String = "Close"
    var shareIcon: UIImage?

    private var scrollSize: CGSize = .zero
    private var imageSize: CGSize = .zero

    private var controlsAreVisible: Bool = false
    private var statusBarHidden: Bool = false
    private var isShown: Bool = false
    private var isLaidOut: Bool = false

    private var lastScale: CGFloat = 1.0
    private var exitScale: CGFloat = 0.0
    private var lastFrame: CGRect?
    private var isTransitioning: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        // Scroll View

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.canCancelContentTouches = false
        scrollView.delegate = self
        scrollView.backgroundColor = .black
        view.addSubview(scrollView)

        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        scrollView.addSubview(imageView)

        animatingImageView.translatesAutoresizingMaskIntoConstraints = true
        animatingImageView.contentMode = .scaleAspectFill
        animatingImageView.clipsToBounds = true
        animatingImageView.backgroundColor = .clear

        // Title View

        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        titleView.isHidden = !controlsAreVisible
        view.addSubview(titleView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        closeButton.setTitle(closeTitle, for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleView.addSubview(closeButton)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        shareButton.setImage(shareIcon, for: .normal)
        shareButton.backgroundColor = .clear
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        shareButton.tintColor = .white
        shareButton.isHidden = shareIcon == nil
        titleView.addSubview(shareButton)

        tapGesture.addTarget(self, action: #selector(toggleTap))
        view.addGestureRecognizer(tapGesture)

        // Loading Indicator

        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.color = .white
        view.addSubview(loadingIndicatorView)

        // Constraints

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 64),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            closeButton.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            shareButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Transition

        transition.startTransition = { [weak self] in
            self?.close()
        }
        transition.shouldStartInteractiveTransition = { [weak self] in
            guard let `self` = self else { return true }

            let orientation = 1 << UInt(UIApplication.shared.statusBarOrientation.rawValue)
            let supportedOrientations = self.presenterInterfaceOrientations?()
                ?? self.presentingViewController?.supportedInterfaceOrientations
                ?? .portrait
            let isFullInteractive = supportedOrientations.rawValue & orientation > 0

            self.transition.interactive = true
            self.transition.sourceTransition = self
            self.lastFrame = nil
            self.isTransitioning = true

            return isFullInteractive
        }
        transition.sourceRootView = { [weak self] in
            return self?.view
        }
        transition.completion = { [weak self] _ in
            guard let `self` = self else { return }

            self.transition.interactive = false
            self.isTransitioning = false
        }
        view.addGestureRecognizer(transition.panGestureRecognizer)

        // Image Loading

        if let fullImage = image.fullImage {
            imageView.image = fullImage
        } else if let previewImage = image.previewImage {
            imageView.image = previewImage
        }
        if let image = imageView.image {
            imageSize = image.size
        }

        // Other

        updateShare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isShown {
            isShown = true

            if let fullImageLoader = image.fullImageLoader, image.fullImage == nil {
                loadingIndicatorView.startAnimating()

                fullImageLoader { [weak self] image, _ in
                    guard let `self` = self else { return }

                    self.loadingIndicatorView.stopAnimating()

                    if let image = image {
                        self.image.fullImage = image
                        self.imageView.image = image

                        let size = image.size
                        let equal = abs(self.imageSize.width - size.width) < 0.1 && abs(self.imageSize.height - size.height) < 0.1
                        if !equal {
                            self.imageSize = size
                            self.scrollSize = self.scrollView.frame.size
                            self.setupScrollView(with: self.scrollSize)
                        }
                    }

                    self.updateShare()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isTransitioning = false

        showControls(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLaidOut {
            isLaidOut = true
            scrollSize = scrollView.frame.size
            setupScrollView(with: scrollSize)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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

    private func showControls(_ show: Bool) {
        controlsAreVisible = show
        statusBarHidden = !show

        if show {
            titleView.alpha = 0
            titleView.isHidden = false
        }

        UIView.animate(withDuration: 0.15, delay: 0, options: [],
            animations: {
                self.setNeedsStatusBarAppearanceUpdate()

                self.titleView.alpha = show ? 1 : 0
            },
            completion: { finished in
                if finished {
                    self.titleView.isHidden = !show
                }
            }
        )
    }

    @objc private func toggleTap() {
        showControls(!controlsAreVisible)
    }

    @objc private func closeTap() {
        isTransitioning = true

        close()
    }

    @objc private func shareTap() {
        guard let image = image.fullImage else { return }

        let controller = UIActivityViewController(activityItems: [ image ], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    private func updateShare() {
        shareButton.isHidden = image.fullImage == nil
    }

    private func close() {
        if let closeAction = closeAction {
            closeAction()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Image

    private func setupScrollView(with size: CGSize) {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        imageView.frame = CGRect(origin: .zero, size: imageSize)

        calcZoom(with: size)
        zoomAll()

        scrollViewDidZoom(scrollView)
    }

    private func calcZoom(with size: CGSize) {
        let contentSize = imageSize
        var minimumScale: CGFloat = 1
        var maximumScale: CGFloat = 1

        if imageSize.width > 0.1 && imageSize.height > 0.1 {
            let xScale = size.width / contentSize.width
            let yScale = size.height / contentSize.height
            minimumScale = min(xScale, yScale)
            maximumScale = max(2.0, minimumScale)
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

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let contentSize = scrollView.contentSize
        guard contentSize != .zero else { return }

        let x = (contentSize.width < scrollSize.width) ? (scrollSize.width - contentSize.width) * 0.5 : 0.0
        let y = (contentSize.height < scrollSize.height) ? (scrollSize.height - contentSize.height) * 0.5 : 0.0
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)

        if scrollView.isZooming {
            lastScale = scrollView.zoomScale
            lastFrame = imageView.convert(imageView.bounds, to: view)
        } else if !isTransitioning && lastScale < exitScale {
            isTransitioning = true

            DispatchQueue.main.async {
                self.closeTap()
            }
        }

        if !isTransitioning {
            let enabled = abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 0.001
            transition.panGestureRecognizer.isEnabled = enabled
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        showControls(false)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        showControls(false)
    }

    // MARK: - Transition

    var zoomTransitionAnimatingView: UIView? {
        animatingImageView.image = imageView.image
        animatingImageView.frame = lastFrame ?? imageView.convert(imageView.bounds, to: view)
        return animatingImageView
    }

    func zoomTransitionHideViews(hide: Bool) {
        imageView.isHidden = hide
        titleView.isHidden = hide || !controlsAreVisible
    }

    func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        var result = frame
        let viewSize = frame.size

        if imageSize.width > 0.1 && imageSize.height > 0.1 {
            let imageRatio = imageSize.height / imageSize.width
            let viewRatio = viewSize.height / viewSize.width

            result.size = imageRatio <= viewRatio
                ? CGSize(
                    width: viewSize.width,
                    height: (viewSize.width * (imageSize.height / imageSize.width)).rounded(.toNearestOrAwayFromZero)
                )
                : CGSize(
                    width: (viewSize.height * (imageSize.width / imageSize.height)).rounded(.toNearestOrAwayFromZero),
                    height: viewSize.height
                )
            result.origin = CGPoint(
                x: (viewSize.width / 2 - result.size.width / 2).rounded(.toNearestOrAwayFromZero),
                y: (viewSize.height / 2 - result.size.height / 2).rounded(.toNearestOrAwayFromZero)
            )
        }

        return result
    }

    private var transition: ZoomTransition = ZoomTransition(interactive: false)

    var zoomTransition: ZoomTransition? {
        return transition
    }

    var zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? {
        return transition.interactive ? transition : nil
    }
}
