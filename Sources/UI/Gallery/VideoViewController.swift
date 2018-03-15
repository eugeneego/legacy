//
// VideoViewController
// EE Gallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE

import UIKit
import AVKit
import AVFoundation

open class VideoViewController: UIViewController, ZoomTransitionDelegate {
    private let titleView: UIView = UIView()
    private let titleContentView: UIView = UIView()
    private let closeButton: UIButton = UIButton(type: .custom)
    private let shareButton: UIButton = UIButton(type: .custom)
    private let playerController: AVPlayerViewController = AVPlayerViewController()
    private let previewImageView: UIImageView = UIImageView()
    private let animatingImageView: UIImageView = UIImageView()
    private let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    private let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

    var video: GalleryMedia.Video = GalleryMedia.Video()

    var autoplay: Bool = true
    var closeAction: (() -> Void)?
    var setupAppearance: ((UIViewController) -> Void)?
    var presenterInterfaceOrientations: (() -> UIInterfaceOrientationMask?)?

    var closeTitle: String = "Close"
    var shareIcon: UIImage?

    private var imageSize: CGSize = .zero

    private var controlsAreVisible: Bool = true
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

        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .clear
        titleView.isUserInteractionEnabled = true
        view.addSubview(titleView)

        titleContentView.translatesAutoresizingMaskIntoConstraints = false
        titleContentView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        titleContentView.isHidden = !controlsAreVisible
        titleView.addSubview(titleContentView)

        closeButton.accessibilityIdentifier = "closeButton"
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        closeButton.setTitle(closeTitle, for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleContentView.addSubview(closeButton)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
        shareButton.setImage(shareIcon, for: .normal)
        shareButton.backgroundColor = .clear
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        shareButton.tintColor = .white
        titleContentView.addSubview(shareButton)

        tapGesture.addTarget(self, action: #selector(toggleTap))
        titleView.addGestureRecognizer(tapGesture)

        // Loading Indicator

        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.color = .white
        view.addSubview(loadingIndicatorView)

        // Constraints

        NSLayoutConstraint.activate([
            // Adding 20 point to the top constraint to avoid AVPlayerViewController's bugs of fullscreen determination.
            playerController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            playerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewImageView.topAnchor.constraint(equalTo: view.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 64),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContentView.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleContentView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            titleContentView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            titleContentView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: titleContentView.bottomAnchor),
            closeButton.leadingAnchor.constraint(equalTo: titleContentView.leadingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.bottomAnchor.constraint(equalTo: titleContentView.bottomAnchor),
            shareButton.trailingAnchor.constraint(equalTo: titleContentView.trailingAnchor),
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

        // Other

        playerController.didMove(toParentViewController: self)

        updatePreviewImage()
        updateShare()
        setupAppearance?(self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isShown {
            isShown = true

            if let url = video.url {
                update(url: url)
            } else if let videoLoader = video.videoLoader {
                loadingIndicatorView.startAnimating()

                videoLoader { [weak self] url, _ in
                    guard let `self` = self else { return }

                    self.loadingIndicatorView.stopAnimating()

                    if let url = url {
                        self.update(url: url)
                    }
                }
            }
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
        return .lightContent
    }

    override open var shouldAutorotate: Bool {
        return true
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    // MARK: - Logic

    private func update(url: URL) {
        video.url = url

        let player = AVPlayer(url: url)
        playerController.player = player
        playerController.showsPlaybackControls = true

        updateShare()

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
            previewImageLoader {  [weak self] image, _ in
                guard let `self` = self else { return }

                if let image = image {
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

    private func showControls(_ show: Bool) {
        controlsAreVisible = show
        statusBarHidden = !show

        if show {
            titleContentView.alpha = 0
            titleContentView.isHidden = false
        }

        UIView.animate(withDuration: 0.15, delay: 0, options: [],
            animations: {
                self.setNeedsStatusBarAppearanceUpdate()

                self.titleContentView.alpha = show ? 1 : 0
            },
            completion: { finished in
                if finished {
                    self.titleContentView.isHidden = !show
                }
            }
        )
    }

    @objc private func toggleTap() {
        showControls(!controlsAreVisible)
    }

    @objc private func closeTap() {
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

    @objc private func shareTap() {
        guard let url = video.url else { return }

        let controller = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    private func updateShare() {
        // Share only local videos
        shareButton.isHidden = !(video.url?.isFileURL ?? false) || shareIcon == nil
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
        titleView.isHidden = hide
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
