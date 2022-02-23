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
    public let prerendered: Bool

    public init(http: Http, prerendered: Bool = true) {
        self.http = http
        self.prerendered = prerendered
    }

    open func load(url: URL, size: CGSize, mode: ResizeMode) async -> ImageLoaderResult {
        actor Render {
            func render(data: Data, prerender: Bool) -> EEImage? {
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
}
