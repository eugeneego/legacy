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

    public typealias PreviewImageLoader = (_ size: CGSize, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void
    public typealias FullImageLoader = (_ completion: @escaping (Result<UIImage, Error>) -> Void) -> Void
    public typealias VideoLoader = (_ completion: @escaping (Result<URL, Error>) -> Void) -> Void

    public struct Image {
        public var previewImage: UIImage?
        public var previewImageLoader: PreviewImageLoader?
        public var fullImage: UIImage?
        public var fullImageLoader: FullImageLoader?

        public init(
            previewImage: UIImage? = nil,
            previewImageLoader: PreviewImageLoader? = nil,
            fullImage: UIImage? = nil,
            fullImageLoader: FullImageLoader? = nil
        ) {
            self.previewImage = previewImage
            self.previewImageLoader = previewImageLoader
            self.fullImage = fullImage
            self.fullImageLoader = fullImageLoader
        }
    }

    public struct Video {
        public var url: URL?
        public var previewImage: UIImage?
        public var previewImageLoader: PreviewImageLoader?
        public var videoLoader: VideoLoader?

        public init(
            url: URL? = nil,
            previewImage: UIImage? = nil,
            previewImageLoader: PreviewImageLoader? = nil,
            videoLoader: VideoLoader? = nil
        ) {
            self.url = url
            self.previewImage = previewImage
            self.previewImageLoader = previewImageLoader
            self.videoLoader = videoLoader
        }
    }
}
