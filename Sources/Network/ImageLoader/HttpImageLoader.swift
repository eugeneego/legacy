//
// HttpImageLoader
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

open class HttpImageLoader: ImageLoader {
    public let http: Http

    public init(http: Http) {
        self.http = http
    }

    open func load(url: URL, size: CGSize, mode: ResizeMode, completion: @escaping ImageLoaderCompletion) -> ImageLoaderTask {
        let task = Task(url: url, size: size, mode: mode)

        let request = http.request(method: .get, url: url, urlParameters: [:], headers: [:], body: nil, bodyStream: nil)
        let httpTask = http.data(request: request) { _, data, error in
            let asyncCompletion = { (result: Result<(data: Data, image: EEImage), ImageLoaderError>) in
                DispatchQueue.main.async {
                    completion(result)
                    task.httpTask = nil
                }
            }

            let processImage = { (data: Data) -> EEImage? in
                #if os(iOS) || os(tvOS) || os(watchOS)
                return EEImage(data: data)?.prerenderedImage()
                #elseif os(macOS)
                return EEImage(data: data)
                #endif
            }

            if let error = error {
                asyncCompletion(.failure(.http(error)))
            } else if let data = data, let image = processImage(data) {
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
