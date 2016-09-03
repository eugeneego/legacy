//
// HttpImageLoader
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public class HttpImageLoader: ImageLoader {
    public let http: Http

    public init(http: Http) {
        self.http = http
    }

    public func load(url url: NSURL, size: CGSize, mode: ResizeMode, completion: ImageLoaderCompletion) -> String {
        let id = NSUUID().UUIDString

        let request = http.request(method: .Get, url: url, urlParameters: [:], headers: [:], body: nil)

        http.data(request: request) { response, data, error in
            let cmpl = { (image: UIImage?, error: ErrorType?) in
                dispatch_async(dispatch_get_main_queue()) {
                    completion(id: id, url: url, data: data, image: image, error: error)
                }
            }

            if let error = error {
                cmpl(nil, HttpError.Error(error: error))
                return
            }

            if let code = response?.statusCode where code >= 400 {
                cmpl(nil, HttpError.Status(code: code, error: error))
                return
            }

            if let data = data {
                let image = UIImage(data: data)?.prerenderedImage()
                cmpl(image, error)
            } else {
                cmpl(nil, HttpError.Error(error: error))
            }
        }

        return id
    }

    public func cancel(id id: String) {
    }
}
