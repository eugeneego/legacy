//
// AppDelegate
// Example-iOS
//
// Created by Eugene Egorov on 24 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TaggedLoggerDependency {
    var window: UIWindow?

    var logger: TaggedLogger?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        self.window = window

        #if DEV
        let baseUrl = "https://dev.base.url"
        guard let url = URL(string: baseUrl) else { fatalError("Invalid base url: \(baseUrl)") }
        let configurator = RestConfigurator(baseUrl: url)
        #elseif STAGING
        let baseUrl = "https://staging.base.url"
        guard let url = URL(string: baseUrl) else { fatalError("Invalid base url: \(baseUrl)") }
        let configurator = RestConfigurator(baseUrl: url)
        #elseif PROD
        let baseUrl = "https://base.url"
        guard let url = URL(string: baseUrl) else { fatalError("Invalid base url: \(baseUrl)") }
        let configurator = RestConfigurator(baseUrl: url)
        #else
        let configurator = MockConfigurator()
        #endif

        let container = configurator.create()

        container.resolve(self)

        // Resolving using a type.
        let resolvedLogger: Logger? = container.resolve()
        resolvedLogger?.debug("Resolved", tag: "ResolvedLogger")

        // Forced resolving using a type.
        let forceResolvedLogger: Logger = container.resolveOrDie()
        forceResolvedLogger.debug("Force resolved", tag: "ForceResolvedLogger")

        // Resolving using dependency protocols associated with the self.
        container.resolve(self)

        let deviceInfo = DeviceInfo.main
        logger?.debug("\(deviceInfo)")

        let appFlow = AppFlow(window: window, container: container)
        appFlow.start()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}
