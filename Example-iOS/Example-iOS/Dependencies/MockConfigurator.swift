//
// MockConfigurator
// Example-iOS
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import UIKit
import EEUtilities

final class MockConfigurator: Configurator {
    private var tabBarController: UITabBarController

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    private let timeout: TimeInterval = 60
    private let imagesMemoryCapacity: Int = 50 * 1024 * 1024
    private let imagesDiskCapacity: Int = 100 * 1024 * 1024

    private func imagesHttp() -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = URLCache(memoryCapacity: imagesMemoryCapacity, diskCapacity: imagesDiskCapacity, diskPath: nil)

        let queue = DispatchQueue.global(qos: .default)

        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue)
        #if DEBUG
        http.logging = true
        http.logOnlyErrors = true
        #endif
        return http
    }

    func create() -> DependencyInjectionContainer {
        let container = Odin()

        let imagesHttp = self.imagesHttp()

        let imageLoader = HttpImageLoader(http: imagesHttp)
        let feedService = MockFeedService()

        container.register { (object: inout ImageLoaderDependency) in
            object.imageLoader = imageLoader
        }

        container.register { (object: inout FeedServiceDependency) in
            object.feedService = feedService
        }

        container.register { [unowned container] (object: inout DependencyContainerDependency) in
            object.container = container
        }

        return container
    }
}
