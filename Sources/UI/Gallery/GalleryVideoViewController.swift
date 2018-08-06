//
// GalleryVideoViewController
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit
import AVKit
import AVFoundation

open class GalleryVideoViewController: UIViewController, GalleryItemViewController, ZoomTransitionDelegate {
    public let titleView: UIView = UIView()
    public let closeButton: UIButton = UIButton(type: .custom)
    public let shareButton: UIButton = UIButton(type: .custom)
    public let playerController: AVPlayerViewController = AVPlayerViewController()
    private let previewImageView: UIImageView = UIImageView()
    private let animatingImageView: UIImageView = UIImageView()
    public let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    private let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

    open var item: GalleryMedia = .video(.init()) {
        didSet {
            if case .video(let video) = item {
                self.video = video
            }
        }
    }

    open var closeAction: (() -> Void)?
    open var setupAppearance: ((GalleryAppearance) -> Void)?
    open var presenterInterfaceOrientations: (() -> UIInterfaceOrientationMask?)?
    open var statusBarStyle: UIStatusBarStyle = .lightContent
    open var isTransitionEnabled: Bool = true

    open var sharedControls: Bool = false
    open var availableControls: GalleryControls = [ .close, .share ]
    open private(set) var controls: GalleryControls = [ .close, .share ]
    open var controlsChanged: (() -> Void)?
    open var initialControlsVisibility: Bool = false
    open private(set) var controlsVisibility: Bool = true
    open var controlsVisibilityChanged: ((Bool) -> Void)?

    open var video: GalleryMedia.Video = .init()
    open var autoplay: Bool = true

    private var imageSize: CGSize = .zero

    private var statusBarHidden: Bool = false
    private var isShown: Bool = false
    private var isStarted: Bool = false
    private var isTransitioning: Bool = false

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        // Video Player

        addChildViewController(playerController)

        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        playerController.showsPlaybackControls = false
        view.addSubview(playerController.view)

        previewImageView.contentMode = .scaleAspectFit
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewImageView)

        animatingImageView.translatesAutoresizingMaskIntoConstraints = true
        animatingImageView.contentMode = .scaleAspectFill
        animatingImageView.clipsToBounds = true
        animatingImageView.backgroundColor = .clear

        // Title View

        GalleryRoutines.configureControllerTitle(view: view, titleView: titleView, closeButton: closeButton, shareButton: shareButton)
        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        tapGesture.addTarget(self, action: #selector(toggleTap))
        titleView.addGestureRecognizer(tapGesture)

        // Loading Indicator

        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.color = .white
        view.addSubview(loadingIndicatorView)

        // Constraints

        NSLayoutConstraint.activate([
            // Adding an inset to the top constraint to avoid AVPlayerViewController's bugs of fullscreen determination.
            playerController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: GalleryRoutines.topInset),
            playerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewImageView.topAnchor.constraint(equalTo: view.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        // Transition

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
            self.pause()
            self.generatePreview()
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

        // Other

        playerController.didMove(toParentViewController: self)

        titleView.isHidden = sharedControls || !controlsVisibility
        showControls(initialControlsVisibility, animated: false)

        updatePreviewImage()
        updateControls()
        setupAppearance?(.video(self))
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isShown {
            isShown = true
            load()
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        pause()
    }

    override open var prefersStatusBarHidden: Bool {
        return statusBarHidden
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

    // MARK: - Logic

    private func load() {
        if let url = video.url {
            load(url: url)
        } else if let videoLoader = video.videoLoader {
            loadingIndicatorView.startAnimating()

            videoLoader { [weak self] result in
                guard let `self` = self else { return }

                self.loadingIndicatorView.stopAnimating()

                if let url = result.value {
                    self.load(url: url)
                }
            }
        }
    }

    private func load(url: URL) {
        video.url = url

        let player = AVPlayer(url: url)
        playerController.player = player
        playerController.showsPlaybackControls = true

        updateControls()

        previewImageView.isHidden = true

        if !isTransitioning && autoplay {
            play()
        }
    }

    private func play() {
        previewImageView.isHidden = true
        playerController.showsPlaybackControls = true
        playerController.view.isHidden = false
        isStarted = true
        playerController.player?.play()
    }

    private func pause() {
        playerController.player?.pause()
    }

    private func updatePreviewImage() {
        if let previewImage = video.previewImage {
            previewImageView.image = previewImage
            imageSize = previewImage.size
        } else if let previewImageLoader = video.previewImageLoader {
            previewImageLoader(.zero) { [weak self] result in
                guard let `self` = self else { return }

                if let image = result.value {
                    self.previewImageView.image = image
                    self.imageSize = image.size
                }
            }
        }
    }

    private func generatePreview() {
        guard let item = playerController.player?.currentItem else { return }

        let asset = item.asset
        let time = item.currentTime()
        if let image = generateVideoPreview(asset: asset, time: time, exact: true) {
            video.previewImage = image
            updatePreviewImage()
        }
    }

    private func generateVideoPreview(asset: AVAsset, time: CMTime = kCMTimeZero, exact: Bool = false) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        if exact {
            imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
            imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
        }
        let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil)
        let image = cgImage.map(UIImage.init)
        return image
    }

    // MARK: - Controls

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

    @objc private func toggleTap() {
        showControls(!controlsVisibility, animated: true)
    }

    @objc open func closeTap() {
        pause()
        generatePreview()

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
        guard let url = video.url else { return }

        let controller = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    private func updateControls() {
        let closeAvailable = availableControls.contains(.close)
        if closeAvailable {
            controls.insert(.close)
        } else {
            controls.remove(.close)
        }
        closeButton.isHidden = !closeAvailable

        // Share only local videos
        let shareAvailable = (video.url?.isFileURL ?? false) && availableControls.contains(.share)
        if shareAvailable {
            controls.insert(.share)
        } else {
            controls.remove(.share)
        }
        shareButton.isEnabled = shareAvailable

        controlsChanged?()
    }

    // MARK: - Transition

    open var zoomTransitionAnimatingView: UIView? {
        animatingImageView.image = video.previewImage

        var frame: CGRect = .zero

        if imageSize.width > 0.1 && imageSize.height > 0.1 {
            let imageFrame = previewImageView.frame
            let widthRatio = imageFrame.width / imageSize.width
            let heightRatio = imageFrame.height / imageSize.height
            let ratio = min(widthRatio, heightRatio)

            let size = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
            let position = CGPoint(
                x: imageFrame.origin.x + (imageFrame.width - size.width) / 2,
                y: imageFrame.origin.y + (imageFrame.height - size.height) / 2
            )

            frame = CGRect(origin: position, size: size)
        }

        animatingImageView.frame = frame

        return animatingImageView
    }

    open func zoomTransitionHideViews(hide: Bool) {
        if !isStarted {
            previewImageView.isHidden = hide
        }
        playerController.view.isHidden = hide
        titleView.isHidden = hide || !controlsVisibility || sharedControls
    }

    open func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect {
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

    open var zoomTransition: ZoomTransition? {
        return transition
    }

    open var zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? {
        return transition.interactive ? transition : nil
    }
}
