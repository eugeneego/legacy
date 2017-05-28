//
// RestConfigurator
// Example-iOS
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import UIKit
import EEUtilities

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

    private func apiHttp() -> Http {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2
        configuration.urlCache = nil

        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue)
        #if DEBUG
        http.logging = true
        http.logOnlyErrors = false
        http.maxLoggingBodySize = 8192
        #endif
        return http
    }

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

    private func feedService(baseUrl: URL, http: Http) -> FeedService {
        let url = baseUrl.appendingPathComponent("feed", isDirectory: true)
        let restClient = BaseRestClient(http: http, baseURL: url, completionQueue: DispatchQueue.main)
        let service = RestFeedService(rest: restClient)
        return service
    }

    func create() -> DependencyInjectionContainer {
        let container = Odin()

        let apiHttp = self.apiHttp()
        let imagesHttp = self.imagesHttp()

        let imageLoader = HttpImageLoader(http: imagesHttp)
        let feedService = self.feedService(baseUrl: baseUrl, http: apiHttp)

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
