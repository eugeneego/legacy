//
// GalleryViewController
// EE Gallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE

import UIKit

open class GalleryViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate,
    ZoomTransitionDelegate {
    open var closeTitle: String = "Close"
    open var shareIcon: UIImage?
    open var setupAppearance: ((UIViewController) -> Void)?

    private var isShown: Bool = false

    public init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        dataSource = self
        delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = "galleryViewController"
        view.backgroundColor = .black

        currentIndex = initialIndex

        let initialViewController = viewController(for: items[currentIndex], autoplay: true)
        setViewControllers([ initialViewController ], direction: .forward, animated: false, completion: nil)

        setupAppearance?(self)
    }

    override open var prefersStatusBarHidden: Bool {
        return currentViewController.prefersStatusBarHidden
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    open private(set) var currentIndex: Int = 0

    private func index(from viewController: UIViewController) -> Int {
        switch viewController {
            case let controller as ImageViewController:
                return controller.image.index
            case let controller as VideoViewController:
                return controller.video.index
            default:
                fatalError("Controller should be ImageViewController or VideoViewController")
        }
    }

    private func viewController(for item: GalleryMedia, autoplay: Bool) -> UIViewController {
        switch item {
            case .image(let image):
                let controller = ImageViewController()
                controller.closeTitle = closeTitle
                controller.shareIcon = shareIcon
                controller.setupAppearance = setupAppearance
                controller.closeAction = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                controller.presenterInterfaceOrientations = { [weak self] in
                    self?.presentingViewController?.supportedInterfaceOrientations
                }
                controller.image = image
                return controller
            case .video(let video):
                let controller = VideoViewController()
                controller.closeTitle = closeTitle
                controller.shareIcon = shareIcon
                controller.setupAppearance = setupAppearance
                controller.closeAction = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                controller.presenterInterfaceOrientations = { [weak self] in
                    self?.presentingViewController?.supportedInterfaceOrientations
                }
                controller.autoplay = autoplay
                controller.video = video
                return controller
        }
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
        let index = self.index(from: currentViewController) - 1
        guard index >= 0 else { return nil }

        let controller = self.viewController(for: items[index], autoplay: true)
        return controller
    }

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let index = self.index(from: currentViewController) + 1
        guard index < items.count else { return nil }

        let controller = self.viewController(for: items[index], autoplay: true)
        return controller
    }

    // MARK: - Delegate

    open func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            currentIndex = index(from: currentViewController)
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
