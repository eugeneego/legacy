//
// ViewController
// Example-iOS
//
// Created by Eugene Egorov on 09 September 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ViewController: UIViewController, TaggedLoggerDependency {
    var logger: TaggedLogger?

    deinit {
        logger?.debug("")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        logger?.debug("")
    }
}
