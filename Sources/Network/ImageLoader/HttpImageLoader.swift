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
    public let completionQueue: DispatchQueue
    public let prerendered: Bool

    public init(http: Http, completionQueue: DispatchQueue = .main, prerendered: Bool = true) {
        self.http = http
        self.completionQueue = completionQueue
        self.prerendered = prerendered
    }

    open func load(url: URL, size: CGSize, mode: ResizeMode, completion: @escaping ImageLoaderCompletion) -> ImageLoaderTask {
        let task = Task(url: url, size: size, mode: mode)
        let httpTask = http.data(request: http.request(parameters: .init(method: .get, url: url)))
        httpTask.completion = { [completionQueue, prerendered] result in
            let processImage = { (data: Data) -> EEImage? in
                let image = EEImage(data: data)
                #if os(iOS) || os(tvOS)
                return prerendered ? image?.prerenderedImage() : image
                #else
                return image
                #endif
            }

            let imageResult: ImageLoaderResult
            if let error = result.error {
                imageResult = .failure(.http(error))
            } else if let data = result.data, let image = processImage(data) {
                imageResult = .success((data, image))
            } else {
                imageResult = .failure(.creating)
            }
            completionQueue.async {
                completion(imageResult)
                task.httpTask = nil
            }
        }
        task.httpTask = httpTask
        httpTask.resume()

        return task
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    open func load(url: URL, size: CGSize, mode: ResizeMode) async -> ImageLoaderResult {
        actor Render {
            func render(data: Data, prerender: Bool) -> UIImage? {
                guard let image = EEImage(data: data) else { return nil }
                #if os(iOS) || os(tvOS)
                return prerender ? image.prerenderedImage() : image
                #else
                return image
                #endif
            }
        }

        let httpResult = await http.data(request: http.request(parameters: .init(method: .get, url: url)))
        if let error = httpResult.error {
            return .failure(.http(error))
        }
        guard let data = httpResult.data, let image = await Render().render(data: data, prerender: prerendered) else {
            return .failure(.creating)
        }
        return .success((data, image))
    }

    private class Task: ImageLoaderTask {
        let url: URL
        let size: CGSize
        let mode: ResizeMode

        var httpTask: HttpDataTask?

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
