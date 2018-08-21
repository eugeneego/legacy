//
// ProfileFlow
// Example-iOS
//
// Created by Eugene Egorov on 19 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ProfileFlow {
    private let container: DependencyInjectionContainer
    private let navigationController: UINavigationController
    private let profileViewController: ProfileViewController

    var viewController: UIViewController {
        return navigationController
    }

    init(container: DependencyInjectionContainer) {
        self.container = container

        profileViewController = UIStoryboard(name: "Main", bundle: nil).instantiate()
        container.resolve(profileViewController)

        navigationController = UINavigationController(rootViewController: profileViewController)
        navigationController.tabBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
    }
}
