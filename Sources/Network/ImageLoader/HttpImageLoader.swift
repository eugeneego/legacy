//
// HttpImageLoader
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class HttpImageLoader: ImageLoader {
    open let http: Http

    public init(http: Http) {
        self.http = http
    }

    open func load(url: URL, size: CGSize, mode: ResizeMode, completion: @escaping ImageLoaderCompletion) -> ImageLoaderTask {
        let task = Task(url: url, size: size, mode: mode)

        let request = http.request(method: .get, url: url, urlParameters: [:], headers: [:], body: nil, bodyStream: nil)
        let httpTask = http.data(request: request) { _, data, error in
            let asyncCompletion = { (result: Result<(Data, UIImage), ImageLoaderError>) in
                DispatchQueue.main.async {
                    completion(result)
                    task.httpTask = nil
                }
            }

            if let error = error {
                asyncCompletion(.failure(.http(error)))
            } else if let data = data, let image = UIImage(data: data)?.prerenderedImage() {
                asyncCompletion(.success((data, image)))
            } else {
                asyncCompletion(.failure(.creating))
            }
        }
        task.httpTask = httpTask
        httpTask.resume()

        return task
    }

    private class Task: ImageLoaderTask {
        let url: URL
        let size: CGSize
        let mode: ResizeMode

        var httpTask: HttpTask?

        init(url: URL, size: CGSize, mode: ResizeMode) {
            self.url = url
            self.size = size
            self.mode = mode
        }

        func cancel() {
            httpTask?.cancel()
        }
    }
}
