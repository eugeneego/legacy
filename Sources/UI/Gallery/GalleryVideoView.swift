//
// GalleryVideoView
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit
import AVFoundation

open class GalleryVideoView: UIView {
    open var player: AVPlayer? {
        get {
            return videoLayer.player
        }
        set {
            videoLayer.player = newValue
        }
    }

    open var videoLayer: AVPlayerLayer {
        guard let videoLayer = layer as? AVPlayerLayer else { fatalError("Layer should be AVPlayerLayer") }

        return videoLayer
    }

    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
