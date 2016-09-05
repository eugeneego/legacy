//
// HttpImageLoader
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

open class HttpImageLoader: ImageLoader {
    open let http: Http

    public init(http: Http) {
        self.http = http
    }

    open func load(url: URL, size: CGSize, mode: ResizeMode, completion: ImageLoaderCompletion) -> String {
        let id = UUID().uuidString

        let request = http.request(method: .get, url: url, urlParameters: [:], headers: [:], body: nil)

        http.data(request: request as URLRequest) { response, data, error in
            let cmpl = { (image: UIImage?, error: Error?) in
                DispatchQueue.main.async {
                    completion(id, url, data, image, error)
                }
            }

            if let error = error {
                cmpl(nil, HttpError.error(error: error))
                return
            }

            if let code = response?.statusCode, code >= 400 {
                cmpl(nil, HttpError.status(code: code, error: error))
                return
            }

            if let data = data {
                let image = UIImage(data: data)?.prerenderedImage()
                cmpl(image, error)
            } else {
                cmpl(nil, HttpError.error(error: error))
            }
        }

        return id
    }

    open func cancel(id: String) {
    }
}
