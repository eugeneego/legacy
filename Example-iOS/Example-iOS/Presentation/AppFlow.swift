//
// AppFlow
// Example-iOS
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class AppFlow {
    private let container: DependencyInjectionContainer
    private let window: UIWindow
    private let tabBarController: TabBarController

    private let mediaFlow: MediaFlow
    private let feedFlow: FeedFlow
    private let profileFlow: ProfileFlow

    init(window: UIWindow, container: DependencyInjectionContainer) {
        self.window = window
        self.container = container

        mediaFlow = MediaFlow(container: container, mediaService: container.resolveOrDie(), imageLoader: container.resolveOrDie())
        feedFlow = FeedFlow(container: container)
        profileFlow = ProfileFlow(container: container)

        window.tintColor = .orange

        tabBarController = TabBarController()
        tabBarController.viewControllers = [
            mediaFlow.viewController,
            feedFlow.viewController,
            profileFlow.viewController,
        ]
    }

    func start() {
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
