//
// ImageLoader
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public typealias ImageLoaderCompletion = (_ id: String, _ url: URL, _ data: Data?, _ image: UIImage?, _ error: Error?) -> Void

public enum ResizeMode {
    case fit
    case fill
    case minimumFit
}

public protocol ImageLoader {
    @discardableResult
    func load(url: URL, size: CGSize, mode: ResizeMode, completion: ImageLoaderCompletion) -> String
    func cancel(id: String)
}
