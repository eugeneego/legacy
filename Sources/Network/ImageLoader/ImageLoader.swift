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
    case unknown(Error?)
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
public typealias ImageLoaderCompletion = (ImageLoaderResult) -> Void

public protocol ImageLoader {
    @discardableResult
    func load(url: URL, size: CGSize, mode: ResizeMode, completion: @escaping ImageLoaderCompletion) -> ImageLoaderTask

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func load(url: URL, size: CGSize, mode: ResizeMode) async -> ImageLoaderResult
}

public extension ImageLoader {
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    func load(url: URL, size: CGSize, mode: ResizeMode) async -> ImageLoaderResult {
        let task = ImageLoaderTaskActor()
        return await withTaskCancellationHandler(
            operation: {
                await withCheckedContinuation { continuation in
                    Task {
                        await task.start(task: load(url: url, size: size, mode: mode, completion: continuation.resume(returning:)))
                    }
                }
            },
            onCancel: {
                Task {
                    await task.cancel()
                }
            }
        )
    }
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
private actor ImageLoaderTaskActor {
    weak var task: ImageLoaderTask?

    func start(task: ImageLoaderTask) {
        self.task = task
    }

    func cancel() {
        task?.cancel()
    }
}
