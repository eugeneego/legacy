//
// ImageLoader
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias EEImage = UIImage
#elseif os(macOS)
import AppKit
public typealias EEImage = NSImage
#endif

public enum ImageLoaderError: Error {
    case http(HttpError)
    case creating
}

public protocol ImageLoaderTask: AnyObject {
    var url: URL { get }
    var size: CGSize { get }
    var mode: ResizeMode { get }

    func cancel()
}

public enum ResizeMode {
    case original
    case fit
    case fill
}

public typealias ImageLoaderResult = Result<(data: Data, image: EEImage), ImageLoaderError>

public protocol ImageLoader {
    func load(url: URL, size: CGSize, mode: ResizeMode) async -> ImageLoaderResult
}
