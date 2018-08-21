//
// FeedFlow
// Example-iOS
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class FeedFlow {
    private let container: DependencyInjectionContainer
    private let navigationController: UINavigationController
    private let feedViewController: FeedViewController

    var viewController: UIViewController {
        return navigationController
    }

    init(container: DependencyInjectionContainer) {
        self.container = container

        feedViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()
        container.resolve(feedViewController)

        navigationController = UINavigationController(rootViewController: feedViewController)
        navigationController.tabBarItem = UITabBarItem(title: "Feed", image: nil, selectedImage: nil)
    }
}
