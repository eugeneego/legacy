//
// GalleryItemViewController
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public struct GalleryControls: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let close = GalleryControls(rawValue: 1)
    public static let share = GalleryControls(rawValue: 2)
}

open class GalleryItemViewController: UIViewController, ZoomTransitionDelegate {
    open var index: Int = 0

    open var closeAction: (() -> Void)?
    open var setupAppearance: ((GalleryAppearance) -> Void)?
    open var presenterInterfaceOrientations: (() -> UIInterfaceOrientationMask?)?
    open var statusBarStyle: UIStatusBarStyle = .lightContent
    open var isTransitionEnabled: Bool = true

    open var autoplay: Bool = true
    open var sharedControls: Bool = true
    open var availableControls: GalleryControls = [ .close, .share ]
    open internal(set) var controls: GalleryControls = [ .close, .share ]
    open var controlsChanged: (() -> Void)?
    open var initialControlsVisibility: Bool = false
    open internal(set) var controlsVisibility: Bool = false
    open var controlsVisibilityChanged: ((Bool) -> Void)?

    internal var mediaSize: CGSize = .zero

    // MARK: - View Controller

    open override func viewDidLoad() {
        super.viewDidLoad()

        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false

        view.backgroundColor = .black
    }

    open override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    open override var shouldAutorotate: Bool {
        return true
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    // MARK: - Controls

    public let titleView: UIView = UIView()
    public let closeButton: UIButton = UIButton(type: .custom)
    public let shareButton: UIButton = UIButton(type: .custom)
    public let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    public let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

    internal var statusBarHidden: Bool = false

    open var isShareAvailable: Bool {
        return false
    }

    open var topInset: CGFloat {
        var topInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            topInset = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        topInset = max(topInset, 20)
        return topInset
    }

    open func setupCommonControls() {
        animatingImageView.translatesAutoresizingMaskIntoConstraints = true
        animatingImageView.contentMode = .scaleAspectFill
        animatingImageView.clipsToBounds = true
        animatingImageView.backgroundColor = .clear

        // Title View

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

        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        tapGesture.addTarget(self, action: #selector(toggleTap))
        view.addGestureRecognizer(tapGesture)

        // Loading Indicator

        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.color = .white
        view.addSubview(loadingIndicatorView)

        // Constraints

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
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Initial state

        titleView.isHidden = sharedControls || !controlsVisibility
        showControls(initialControlsVisibility, animated: false)

        updateControls()
        setupAppearance?(.item(self))
    }

    open func showControls(_ show: Bool, animated: Bool) {
        controlsVisibility = show
        statusBarHidden = !show

        guard !sharedControls else {
            controlsVisibilityChanged?(controlsVisibility)
            return
        }

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

    @objc open func toggleTap() {
        showControls(!controlsVisibility, animated: true)
    }

    @objc open func closeTap() {
        isTransitioning = true

        close()
    }

    private func close() {
        if let closeAction = closeAction {
            closeAction()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc open func shareTap() {
        // to be overridden
    }

    internal func updateControls() {
        let closeAvailable = availableControls.contains(.close)
        if closeAvailable {
            controls.insert(.close)
        } else {
            controls.remove(.close)
        }
        closeButton.isHidden = !closeAvailable

        // Share only local videos
        let shareAvailable = isShareAvailable && availableControls.contains(.share)
        if shareAvailable {
            controls.insert(.share)
        } else {
            controls.remove(.share)
        }
        shareButton.isEnabled = shareAvailable

        controlsChanged?()
    }

    // MARK: - Transition

    internal var isTransitioning: Bool = false
    internal var transition: ZoomTransition = ZoomTransition(interactive: false)
    internal var animatingImageView: UIImageView = UIImageView()

    open func setupTransition() {
        transition.startTransition = { [weak self] in
            self?.close()
        }
        transition.shouldStartInteractiveTransition = { [weak self] in
            guard let `self` = self else { return true }

            let orientation: UInt = 1 << UIApplication.shared.statusBarOrientation.rawValue
            let supportedOrientations = self.presenterInterfaceOrientations?()
                ?? self.presentingViewController?.supportedInterfaceOrientations
                ?? .portrait
            let isFullInteractive = supportedOrientations.rawValue & orientation > 0

            self.transition.interactive = true
            self.transition.sourceTransition = self

            self.zoomTransitionOnStart()

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
        transition.panGestureRecognizer.isEnabled = isTransitionEnabled
    }

    open func zoomTransitionOnStart() {
        // to be overridden
    }

    open var zoomTransition: ZoomTransition? {
        return transition
    }

    open var zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? {
        return transition.interactive ? transition : nil
    }

    open var zoomTransitionAnimatingView: UIView? {
        zoomTransitionPrepareAnimatingView(animatingImageView)
        return animatingImageView
    }

    open func zoomTransitionPrepareAnimatingView(_ animatingImageView: UIImageView) {
        // to be overridden
    }

    open func zoomTransitionHideViews(hide: Bool) {
        titleView.isHidden = hide || !controlsVisibility || sharedControls
    }

    open func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
        var result = frame
        let viewSize = frame.size

        if mediaSize.width > 0.1 && mediaSize.height > 0.1 {
            let imageRatio = mediaSize.height / mediaSize.width
            let viewRatio = viewSize.height / viewSize.width

            result.size = imageRatio <= viewRatio
                ? CGSize(
                width: viewSize.width,
                height: (viewSize.width * (mediaSize.height / mediaSize.width)).rounded(.toNearestOrAwayFromZero)
            )
                : CGSize(
                width: (viewSize.height * (mediaSize.width / mediaSize.height)).rounded(.toNearestOrAwayFromZero),
                height: viewSize.height
            )
            result.origin = CGPoint(
                x: (viewSize.width / 2 - result.size.width / 2).rounded(.toNearestOrAwayFromZero),
                y: (viewSize.height / 2 - result.size.height / 2).rounded(.toNearestOrAwayFromZero)
            )
        }

        return result
    }
}
