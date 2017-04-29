//
// AppDelegate
// Example-iOS
//
// Created by Eugene Egorov on 24 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import UIKit
import EEUtilities

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        self.window = window

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = mainStoryboard.instantiateInitialViewController() as? UITabBarController else {
            fatalError("Invalid initial view controller")
        }

        #if MOCK
        let configurator = MockConfigurator(tabBarController: tabBarController)
        #elseif DEV
        let configurator = RestConfigurator(
            baseUrl: URL(string: "https://dev.base.url")!,
            tabBarController: tabBarController
        )
        #elseif STAGING
        let configurator = RestConfigurator(
            baseUrl: URL(string: "https://staging.base.url")!,
            tabBarController: tabBarController
        )
        #else
        let configurator = RestConfigurator(
            baseUrl: URL(string: "https://base.url")!,
            tabBarController: tabBarController
        )
        #endif
        let container = configurator.create()
        container.resolve(self)
        tabBarController.viewControllers?.forEach { controller in
            container.resolve(controller)
            (controller as? UINavigationController)?.viewControllers.forEach(container.resolve)
        }

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

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
