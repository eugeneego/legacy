//
// ImageLoader
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public typealias ImageLoaderCompletion = (id: String, url: NSURL, data: NSData?, image: UIImage?, error: ErrorType?) -> Void

public enum ResizeMode {
    case Fit
    case Fill
    case MinimumFit
}

public protocol ImageLoader {
    func load(url url: NSURL, size: CGSize, mode: ResizeMode, completion: ImageLoaderCompletion) -> String
    func cancel(id id: String)
}
