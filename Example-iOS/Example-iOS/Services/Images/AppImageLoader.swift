//
// AppImageLoader
// Example-iOS
//
// Created by Eugene Egorov on 05 September 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class AppImageLoader: ImageLoader {
    private let imageLoader: ImageLoader

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }

    func load(url: URL, size: CGSize, mode: ResizeMode, completion: @escaping ImageLoaderCompletion) -> ImageLoaderTask {
        let task = Task(url: url, size: size, mode: mode)
        let load = { (dataUrl: URL?) in
            if let dataUrl = dataUrl, let data = try? Data(contentsOf: dataUrl), let image = UIImage(data: data)?.prerenderedImage() {
                DispatchQueue.main.async {
                    completion(.success((data, image)))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.creating))
                }
            }
        }
        if url.scheme == "app" {
            DispatchQueue.global(qos: .default).async {
                let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let dataUrl = Bundle.main.url(forResource: path, withExtension: nil)
                load(dataUrl)
            }
            return task
        } else if let scheme = url.scheme, let directory = Storage.schemeDirectories[scheme] {
            DispatchQueue.global(qos: .default).async {
                let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let dataUrl = directory.appendingPathComponent(path)
                load(dataUrl)
            }
            return task
        } else {
            return imageLoader.load(url: url, size: size, mode: mode, completion: completion)
        }
    }

    private class Task: ImageLoaderTask {
        let url: URL
        let size: CGSize
        let mode: ResizeMode

        init(url: URL, size: CGSize, mode: ResizeMode) {
            self.url = url
            self.size = size
            self.mode = mode
        }

        func cancel() {
        }
    }
}
