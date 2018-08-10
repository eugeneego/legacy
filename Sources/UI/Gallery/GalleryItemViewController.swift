//
// GalleryItemViewController
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public struct GalleryControls: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let close = GalleryControls(rawValue: 1)
    public static let share = GalleryControls(rawValue: 2)
}

public protocol GalleryItemViewController: class {
    var item: GalleryMedia { get set }

    var closeAction: (() -> Void)? { get set }
    var setupAppearance: ((GalleryAppearance) -> Void)? { get set }
    var presenterInterfaceOrientations: (() -> UIInterfaceOrientationMask?)? { get set }
    var statusBarStyle: UIStatusBarStyle { get set }
    var isTransitionEnabled: Bool { get set }

    var sharedControls: Bool { get set }
    var availableControls: GalleryControls { get set }
    var controls: GalleryControls { get }
    var controlsChanged: (() -> Void)? { get set }
    var initialControlsVisibility: Bool { get set }
    var controlsVisibility: Bool { get }
    var controlsVisibilityChanged: ((Bool) -> Void)? { get set }
    func showControls(_ show: Bool, animated: Bool)
    func closeTap()
    func shareTap()
}
