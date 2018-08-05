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
    open var setupAppearance: ((GalleryAppearance) -> Void)?
    open var viewAppeared: ((GalleryViewController) -> Void)?
    open var pageChanged: ((_ currentIndex: Int) -> Void)?
    open var initialControlsVisibility: Bool = false
    open var controlsVisibilityChanged: ((Bool) -> Void)?
    open var statusBarStyle: UIStatusBarStyle = .lightContent

    open var transitionController: ZoomTransitionController? {
        didSet {
            transitioningDelegate = transitionController
        }
    }

    private var lastControlsVisibility: Bool = false

    public init(spacing: CGFloat = 0) {
        let options: [String: Any] = [ UIPageViewControllerOptionInterPageSpacingKey: spacing ]
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)

        dataSource = self
        delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        lastControlsVisibility = initialControlsVisibility

        setupAppearance?(.gallery(self))

        move(to: initialIndex, animated: false)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewAppeared?(self)
    }

    override open var prefersStatusBarHidden: Bool {
        return currentViewController.prefersStatusBarHidden
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

    // MARK: - Models

    open var items: [GalleryMedia] = []
    open var initialIndex: Int = 0
    open private(set) var currentIndex: Int = -1

    open func move(to index: Int, animated: Bool) {
        guard index != currentIndex, items.indices.contains(index) else { return }

        let direction: UIPageViewControllerNavigationDirection = index >= currentIndex ? .forward : .reverse

        currentIndex = index

        let controller = viewController(for: items[currentIndex], autoplay: true, controls: lastControlsVisibility)
        setViewControllers([ controller ], direction: direction, animated: animated) { completed in
            if completed {
                self.pageChanged?(self.currentIndex)
            }
        }
    }

    private func index(from viewController: UIViewController) -> Int {
        guard let controller = viewController as? GalleryItemViewController else { fatalError("Should be GalleryItemViewController") }

        return controller.item.index
    }

    private func viewController(for item: GalleryMedia, autoplay: Bool, controls: Bool) -> UIViewController {
        let controller: UIViewController & GalleryItemViewController

        switch item {
            case .image:
                controller = GalleryImageViewController()
            case .video:
                let videoController = GalleryVideoViewController()
                videoController.autoplay = autoplay
                controller = videoController
        }

        controller.setupAppearance = setupAppearance
        controller.initialControlsVisibility = controls
        controller.controlsVisibilityChanged = controlsVisibilityChanged
        controller.closeAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        controller.presenterInterfaceOrientations = { [weak self] in
            self?.presentingViewController?.supportedInterfaceOrientations
        }
        controller.isTransitionEnabled = transitionController != nil
        controller.item = item
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
        let controller = viewController(for: items[index], autoplay: true, controls: lastControlsVisibility)
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
