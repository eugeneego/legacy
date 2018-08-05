//
// GalleryItemViewController
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public protocol GalleryItemViewController: class {
    var item: GalleryMedia { get set }

    var closeAction: (() -> Void)? { get set }
    var setupAppearance: ((GalleryAppearance) -> Void)? { get set }
    var presenterInterfaceOrientations: (() -> UIInterfaceOrientationMask?)? { get set }
    var statusBarStyle: UIStatusBarStyle { get set }

    var initialControlsVisibility: Bool { get set }
    var controlsVisibility: Bool { get }
    var controlsVisibilityChanged: ((Bool) -> Void)? { get set }
    func showControls(_ show: Bool, animated: Bool)
}
