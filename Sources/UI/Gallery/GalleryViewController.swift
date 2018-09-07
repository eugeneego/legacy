//
// GalleryViewController
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class GalleryViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate,
        ZoomTransitionDelegate {
    open var viewerForItem: (GalleryMedia) -> GalleryItemViewController = { item in
        switch item {
            case .image(let image):
                return GalleryImageViewController(image: image)
            case .video(let video):
                return GalleryVideoViewController(video: video)
        }
    }

    open var setupAppearance: ((GalleryViewController) -> Void)?
    open var viewAppeared: ((GalleryViewController) -> Void)?
    open var pageChanged: ((_ currentIndex: Int) -> Void)?
    open var statusBarStyle: UIStatusBarStyle = .lightContent

    open var sharedControls: Bool = false
    open var availableControls: GalleryControls = [ .close, .share ]
    open var initialControlsVisibility: Bool = false
    open private(set) var controlsVisibility: Bool = false
    open var controlsVisibilityChanged: ((Bool) -> Void)?

    open var transitionController: ZoomTransitionController? {
        didSet {
            transitioningDelegate = transitionController
        }
    }

    public let titleView: UIView = UIView()
    public let closeButton: UIButton = UIButton(type: .custom)
    public let shareButton: UIButton = UIButton(type: .custom)
    private let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

    private var lastControlsVisibility: Bool = false
    private var statusBarHidden: Bool = false

    public init(spacing: CGFloat = 0) {
        let options: [String: Any] = [ UIPageViewControllerOptionInterPageSpacingKey: spacing ]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)

        dataSource = self
        delegate = self
    }

    required public init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        dataSource = self
        delegate = self
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        lastControlsVisibility = initialControlsVisibility

        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        titleView.isUserInteractionEnabled = true
        view.addSubview(titleView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleView.addSubview(closeButton)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = .clear
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleView.addSubview(shareButton)

        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: topInset + 44),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            closeButton.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            shareButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        tapGesture.addTarget(self, action: #selector(toggleTap))
        titleView.addGestureRecognizer(tapGesture)

        titleView.isHidden = !sharedControls || !controlsVisibility
        showControls(initialControlsVisibility, animated: false)

        setupAppearance?(self)

        move(to: initialIndex, animated: false)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewAppeared?(self)
    }

    override open var prefersStatusBarHidden: Bool {
        return sharedControls ? statusBarHidden : currentViewController.prefersStatusBarHidden
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override open var shouldAutorotate: Bool {
        return true
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    open var topInset: CGFloat {
        var topInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            topInset = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        topInset = max(topInset, 20)
        return topInset
    }

    // MARK: - Controls

    open func showControls(_ show: Bool, animated: Bool) {
        lastControlsVisibility = show
        controlsVisibility = show
        statusBarHidden = !show

        guard sharedControls else { return }

        if show {
            titleView.isHidden = false
        }

        UIView.animate(withDuration: animated ? 0.15 : 0, delay: 0, options: [],
            animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.titleView.alpha = show ? 1 : 0
                self.controlsVisibilityChanged?(self.controlsVisibility)
            },
            completion: { finished in
                if finished {
                    self.titleView.isHidden = !show
                }
            }
        )
    }

    open func updateControls() {
        let controls: GalleryControls = (currentViewController as? GalleryItemViewController)?.controls ?? []
        closeButton.isHidden = !controls.contains(.close)
        shareButton.isHidden = !controls.contains(.share)
    }

    @objc private func toggleTap() {
        (currentViewController as? GalleryItemViewController)?.showControls(!controlsVisibility, animated: true)
    }

    @objc private func closeTap() {
        (currentViewController as? GalleryItemViewController)?.closeTap()
    }

    @objc private func shareTap() {
        (currentViewController as? GalleryItemViewController)?.shareTap()
    }

    // MARK: - Models

    open var items: [GalleryMedia] = []
    open var initialIndex: Int = 0
    open private(set) var currentIndex: Int = -1

    open func move(to index: Int, animated: Bool) {
        guard index != currentIndex, items.indices.contains(index) else { return }

        let direction: UIPageViewControllerNavigationDirection = index >= currentIndex ? .forward : .reverse

        currentIndex = index

        let controller = viewController(item: items[currentIndex], index: currentIndex, autoplay: true, controls: lastControlsVisibility)
        setViewControllers([ controller ], direction: direction, animated: animated) { completed in
            if completed {
                self.pageChanged?(self.currentIndex)
            }
        }
    }

    private func index(from viewController: UIViewController) -> Int {
        guard let controller = viewController as? GalleryItemViewController else { fatalError("Should be GalleryItemViewController") }

        return controller.index
    }

    private func viewController(item: GalleryMedia, index: Int, autoplay: Bool, controls: Bool) -> UIViewController {
        let controller = viewerForItem(item)
        controller.index = index
        controller.autoplay = autoplay
        controller.sharedControls = sharedControls
        controller.availableControls = availableControls
        controller.controlsChanged = { [weak self] in
            self?.updateControls()
        }
        controller.initialControlsVisibility = controls
        controller.controlsVisibilityChanged = { [weak self] controlsVisibility in
            guard let `self` = self else { return }

            self.showControls(controlsVisibility, animated: true)
            self.controlsVisibilityChanged?(controlsVisibility)
        }
        controller.closeAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        controller.presenterInterfaceOrientations = { [weak self] in
            self?.presentingViewController?.supportedInterfaceOrientations
        }
        controller.isTransitionEnabled = transitionController != nil
        return controller
    }

    private var currentViewController: UIViewController {
        guard let viewControllers = viewControllers else { fatalError("Cannot get view controllers from UIPageViewController") }
        return viewControllers[0]
    }

    // MARK: - Data Source

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let current = currentViewController
        let index = self.index(from: current) - 1
        guard index >= 0 else { return nil }

        return controller(for: index, previousViewController: current)
    }

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let current = currentViewController
        let index = self.index(from: current) + 1
        guard index < items.count else { return nil }

        return controller(for: index, previousViewController: current)
    }

    private func controller(for index: Int, previousViewController: UIViewController) -> UIViewController {
        lastControlsVisibility = (previousViewController as? GalleryItemViewController)?.controlsVisibility ?? lastControlsVisibility
        let controller = viewController(item: items[index], index: index, autoplay: true, controls: lastControlsVisibility)
        return controller
    }

    // MARK: - Delegate

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        let controls = (currentViewController as? GalleryItemViewController)?.controlsVisibility ?? initialControlsVisibility
        pendingViewControllers
            .compactMap { $0 as? GalleryItemViewController }
            .forEach { $0.showControls(controls, animated: false) }
    }

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            currentIndex = index(from: currentViewController)
            pageChanged?(currentIndex)
        }
    }

    open func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        return .all
    }

    // MARK: - Transition

    open var zoomTransitionAnimatingView: UIView? {
        guard let transitionDelegate = currentViewController as? ZoomTransitionDelegate else { return nil }

        return transitionDelegate.zoomTransitionAnimatingView
    }

    open func zoomTransitionHideViews(hide: Bool) {
        guard let transitionDelegate = currentViewController as? ZoomTransitionDelegate else { return }

        transitionDelegate.zoomTransitionHideViews(hide: hide)
    }

    open func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        guard let transitionDelegate = currentViewController as? ZoomTransitionDelegate else { return .zero }

        return transitionDelegate.zoomTransitionDestinationFrame(for: view, frame: frame)
    }

    open var zoomTransition: ZoomTransition? {
        guard let transitionDelegate = currentViewController as? ZoomTransitionDelegate else { return nil }

        return transitionDelegate.zoomTransition
    }

    open var zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? {
        guard let transitionDelegate = currentViewController as? ZoomTransitionDelegate else { return nil }

        return (transitionDelegate.zoomTransition?.interactive ?? false) ? transitionDelegate.zoomTransition : nil
    }
}
