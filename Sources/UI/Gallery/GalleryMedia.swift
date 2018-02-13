//
// GalleryMedia
// EE Gallery
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE

import UIKit

public enum GalleryMedia {
    case image(Image)
    case video(Video)

    public struct Image {
        var index: Int = 0
        var previewImage: UIImage?
        var fullImage: UIImage?
        var fullImageLoader: ((_ completion: @escaping (UIImage?, Error?) -> Void) -> Void)?
    }

    public struct Video {
        var index: Int = 0
        var url: URL?
        var previewImage: UIImage?
        var previewImageLoader: ((_ completion: @escaping (UIImage?, Error?) -> Void) -> Void)?
        var videoLoader: ((_ completion: @escaping (URL?, Error?) -> Void) -> Void)?
    }
}
