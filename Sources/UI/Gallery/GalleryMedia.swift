//
// GalleryMedia
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public enum GalleryMedia {
    case image(Image)
    case video(Video)

    public struct Image {
        public typealias FullImageLoader = (_ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void

        var index: Int = 0
        var previewImage: UIImage?
        var fullImage: UIImage?
        var fullImageLoader: FullImageLoader?

        public init(index: Int = 0, previewImage: UIImage? = nil, fullImage: UIImage? = nil, fullImageLoader: FullImageLoader? = nil) {
            self.index = index
            self.previewImage = previewImage
            self.fullImage = fullImage
            self.fullImageLoader = fullImageLoader
        }
    }

    public struct Video {
        public typealias PreviewImageLoader = (_ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void
        public typealias VideoLoader = (_ completion: @escaping (Result<URL, Error>) -> Void) -> Void

        var index: Int = 0
        var url: URL?
        var previewImage: UIImage?
        var previewImageLoader: PreviewImageLoader?
        var videoLoader: VideoLoader?

        public init(index: Int = 0, url: URL? = nil, previewImage: UIImage? = nil, previewImageLoader: PreviewImageLoader? = nil,
                videoLoader: VideoLoader? = nil) {
            self.index = index
            self.url = url
            self.previewImage = previewImage
            self.previewImageLoader = previewImageLoader
            self.videoLoader = videoLoader
        }
    }
}
