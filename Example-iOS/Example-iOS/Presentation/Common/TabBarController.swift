//
// TabBarController
// Example-iOS
//
// Created by Eugene Egorov on 05 August 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
