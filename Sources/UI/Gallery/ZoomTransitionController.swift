//
// ZoomTransitionController
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class ZoomTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    open weak var sourceTransition: ZoomTransitionDelegate?

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController)
            -> UIViewControllerAnimatedTransitioning? {
        guard
            let sourceTransition = source as? ZoomTransitionDelegate,
            let destinationTransition = presented as? ZoomTransitionDelegate
        else { return nil }

        self.sourceTransition = sourceTransition

        let transition = ZoomTransition(interactive: false)
        transition.sourceTransition = sourceTransition
        transition.destinationTransition = destinationTransition
        return transition
    }

    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
            let sourceTransition = dismissed as? ZoomTransitionDelegate,
            let destinationTransition = self.sourceTransition
        else { return nil }

        let transition = sourceTransition.zoomTransition ?? ZoomTransition(interactive: false)
        transition.sourceTransition = sourceTransition
        transition.destinationTransition = destinationTransition
        return transition
    }

    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
            -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
            -> UIViewControllerInteractiveTransitioning? {
        guard let transition = animator as? ZoomTransition else { return nil }

        return transition.interactive ? transition : nil
    }
}
