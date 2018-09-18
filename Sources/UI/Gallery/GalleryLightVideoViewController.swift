//
// GalleryLightVideoViewController
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit
import AVFoundation

open class GalleryLightVideoViewController: GalleryItemViewController {
    public let video: GalleryMedia.Video
    private var url: URL?
    private var previewImage: UIImage?

    open var loop: Bool = true

    open var setupAppearance: ((GalleryLightVideoViewController) -> Void)?

    private var isShown: Bool = false
    private var isStarted: Bool = false

    public let videoView: GalleryVideoView = GalleryVideoView()
    public let previewImageView: UIImageView = UIImageView()
    public let progressView: UIProgressView = UIProgressView(progressViewStyle: .default)

    public init(video: GalleryMedia.Video) {
        self.video = video
        url = video.url
        previewImage = video.previewImage

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        videoView.clipsToBounds = true
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)

        previewImageView.contentMode = .scaleAspectFit
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewImageView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .clear
        view.addSubview(progressView)

        // Constraints

        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewImageView.topAnchor.constraint(equalTo: view.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // Other

        setupTransition()
        setupCommonControls()
        setupAppearance?(self)

        updatePreviewImage()
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

    // MARK: - Controls

    open override func toggleTap() {
        super.toggleTap()

        if controlsVisibility {
            pause()
        } else {
            play()
        }
    }

    // MARK: - Logic

    private func load() {
        if let url = url {
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
        self.url = url

        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        videoView.player = player

        let interval = CMTime(seconds: 0.016, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            self?.updatePlaybackProgress()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playbackEnded), name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem)

        updateControls()

        previewImageView.isHidden = true

        if !isTransitioning && autoplay {
            play()
        }
    }

    private func play() {
        previewImageView.isHidden = true
        videoView.isHidden = false
        isStarted = true
        videoView.player?.play()
    }

    private func pause() {
        videoView.player?.pause()
    }

    private func updatePlaybackProgress() {
        let item = videoView.player?.currentItem
        let time = item?.currentTime()
        let duration = item?.duration
        if let time = time, time.isValid, !time.isIndefinite, let duration = duration, duration.isValid, !duration.isIndefinite {
            progressView.progress = Float(time.seconds / duration.seconds)
        } else {
            progressView.progress = 0
        }
    }

    @objc private func playbackEnded(_ notification: Notification) {
        (notification.object as? AVPlayerItem)?.seek(to: kCMTimeZero)
        if !loop {
            pause()
        }
    }

    private func updatePreviewImage() {
        if let previewImage = previewImage {
            previewImageView.image = previewImage
            mediaSize = previewImage.size
        } else if let previewImageLoader = video.previewImageLoader {
            previewImageLoader(.zero) { [weak self] result in
                guard let `self` = self else { return }

                if let image = result.value {
                    self.previewImage = image
                    self.previewImageView.image = image
                    self.mediaSize = image.size
                }
            }
        }
    }

    private func generatePreview() {
        guard let item = videoView.player?.currentItem else { return }

        let asset = item.asset
        let time = item.currentTime()
        if let image = generateVideoPreview(asset: asset, time: time, exact: true) {
            previewImage = image
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

    open override var isShareAvailable: Bool {
        return url?.isFileURL ?? false
    }

    open override func closeTap() {
        pause()
        generatePreview()

        super.closeTap()
    }

    open override func shareTap() {
        guard let url = url else { return }

        let controller = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Transition

    open override func zoomTransitionPrepareAnimatingView(_ animatingImageView: UIImageView) {
        super.zoomTransitionPrepareAnimatingView(animatingImageView)

        animatingImageView.image = previewImage

        var frame: CGRect = .zero

        if mediaSize.width > 0.1 && mediaSize.height > 0.1 {
            let imageFrame = previewImageView.frame
            let widthRatio = imageFrame.width / mediaSize.width
            let heightRatio = imageFrame.height / mediaSize.height
            let ratio = min(widthRatio, heightRatio)

            let size = CGSize(width: mediaSize.width * ratio, height: mediaSize.height * ratio)
            let position = CGPoint(
                x: imageFrame.origin.x + (imageFrame.width - size.width) / 2,
                y: imageFrame.origin.y + (imageFrame.height - size.height) / 2
            )
            frame = CGRect(origin: position, size: size)
        }

        animatingImageView.frame = frame
    }

    open override func zoomTransitionOnStart() {
        super.zoomTransitionOnStart()

        pause()
        generatePreview()
    }

    open override func zoomTransitionHideViews(hide: Bool) {
        super.zoomTransitionHideViews(hide: hide)

        if !isStarted {
            previewImageView.isHidden = hide
        }
        videoView.isHidden = hide
    }
}
