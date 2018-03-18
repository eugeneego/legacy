//
// RestConfigurator
// Example-iOS
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class RestConfigurator: Configurator {
    private let baseUrl: URL
    private var tabBarController: UITabBarController

    init(baseUrl: URL, tabBarController: UITabBarController) {
        self.baseUrl = baseUrl
        self.tabBarController = tabBarController
    }

    private let timeout: TimeInterval = 60
    private let imagesMemoryCapacity: Int = 50 * 1024 * 1024
    private let imagesDiskCapacity: Int = 100 * 1024 * 1024

    private func apiHttp(logger: Logger) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = nil

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger)
        return http
    }

    private func imagesHttp(logger: Logger) -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = URLCache(memoryCapacity: imagesMemoryCapacity, diskCapacity: imagesDiskCapacity, diskPath: nil)

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: logger)
        return http
    }

    private func feedService(baseUrl: URL, http: Http) -> FeedService {
        let url = baseUrl.appendingPathComponent("feed", isDirectory: true)
        let queue = DispatchQueue.global(qos: .default)
        let restClient = BaseRestClient(http: http, baseURL: url, workQueue: queue, completionQueue: DispatchQueue.main)
        let service = RestFeedService(rest: restClient)
        return service
    }

    func create() -> DependencyInjectionContainer {
        let container = Odin()

        let logger: Logger = PrintLogger()
        let apiHttp = self.apiHttp(logger: logger)
        let imagesHttp = self.imagesHttp(logger: logger)

        let imageLoader = HttpImageLoader(http: imagesHttp)
        let feedService = self.feedService(baseUrl: baseUrl, http: apiHttp)

        // Registering protocols resolvers.
        container.register { (object: inout LoggerDependency) in object.logger = logger }
        container.register { (object: inout ImageLoaderDependency) in object.imageLoader = imageLoader }
        container.register { (object: inout FeedServiceDependency) in object.feedService = feedService }
        container.register { [unowned container] (object: inout DependencyContainerDependency) in object.container = container }

        // Registering type resolvers.
        container.register { () -> Logger in logger }
        container.register { () -> ImageLoader in imageLoader }
        container.register { () -> FeedService in feedService }

        return container
    }
}
