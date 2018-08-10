//
// ZoomTransition
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

public protocol ZoomTransitionDelegate: class {
    var zoomTransition: ZoomTransition? { get }
    var zoomTransitionInteractionController: UIViewControllerInteractiveTransitioning? { get }

    var zoomTransitionAnimatingView: UIView? { get }

    func zoomTransitionHideViews(hide: Bool)
    func zoomTransitionDestinationFrame(for view: UIView, frame: CGRect) -> CGRect
}

open class ZoomTransition: NSObject,
        UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {
    open weak var sourceTransition: ZoomTransitionDelegate?
    open weak var destinationTransition: ZoomTransitionDelegate?

    open var interactive: Bool

    open var shouldStartInteractiveTransition: (() -> Bool)?
    open var startTransition: (() -> Void)?
    open var sourceRootView: (() -> UIView?)?

    open var animationSetup: ((_ view: UIView) -> Void)?
    open var animation: ((_ view: UIView, _ duration: TimeInterval) -> Void)?

    open var completion: ((_ completed: Bool) -> Void)?

    private let zoomDuration: TimeInterval = 0.3
    private let minimumZoomDuration: TimeInterval = 0.15

    public let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()

    public init(interactive: Bool) {
        self.interactive = interactive

        super.init()

        panGestureRecognizer.addTarget(self, action: #selector(panGestureAction))
        panGestureRecognizer.delegate = self
    }

    // MARK: - Non interactive transition

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return zoomDuration
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard !interactive else { return }

        // Getting view controllers and views

        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }

        let toFinalFrame = transitionContext.finalFrame(for: toVC)

        let containerView = transitionContext.containerView

        toView.frame = toFinalFrame
        containerView.addSubview(toView)

        // Getting animating view and destination frame after applying frames to views

        let semiAnimatingFrame = semiInteractiveTransitionContext?.animatingView.frame

        guard
            let animatingView = sourceTransition?.zoomTransitionAnimatingView,
            let destinationFrame = destinationTransition?.zoomTransitionDestinationFrame(for: animatingView, frame: toFinalFrame)
        else { return }

        let animatingFrame = containerView.convert(semiAnimatingFrame ?? animatingView.frame, from: fromView)
        animatingView.transform = fromView.transform
        animatingView.frame = animatingFrame
        containerView.addSubview(animatingView)

        sourceTransition?.zoomTransitionHideViews(hide: true)
        destinationTransition?.zoomTransitionHideViews(hide: true)

        fromView.alpha = 1
        toView.alpha = 0

        animationSetup?(animatingView)

        UIView.animate(withDuration: zoomDuration, delay: 0, options: [ .curveEaseOut ],
            animations: {
                animatingView.transform = .identity
                animatingView.frame = destinationFrame

                fromView.alpha = 0
                toView.alpha = 1

                self.animation?(animatingView, self.zoomDuration)
            },
            completion: { _ in
                self.sourceTransition?.zoomTransitionHideViews(hide: false)
                self.destinationTransition?.zoomTransitionHideViews(hide: false)
                animatingView.removeFromSuperview()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }

    open func animationEnded(_ transitionCompleted: Bool) {
        completion?(transitionCompleted)

        interactiveTransitionContext?.animatingView.removeFromSuperview()
        interactiveTransitionContext = nil

        semiInteractiveTransitionContext?.animatingView.removeFromSuperview()
        semiInteractiveTransitionContext = nil

        isFullInteractive = true
    }

    // MARK: - Normal interactive transition

    private struct InteractiveTransitionContext {
        var transitionContext: UIViewControllerContextTransitioning

        let fromViewController: UIViewController
        let toViewController: UIViewController
        let fromView: UIView
        let toView: UIView

        var animatingView: UIView
        var animatingViewInitialPosition: CGPoint = .zero

        var progress: CGFloat = 0
        var progressDistance: CGFloat = 0
    }

    private var interactiveTransitionContext: InteractiveTransitionContext?

    open func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard interactive else { return }

        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }

        let toFinalFrame = transitionContext.finalFrame(for: toVC)

        let containerView = transitionContext.containerView

        toView.frame = toFinalFrame
        containerView.insertSubview(toView, belowSubview: fromView)

        // Getting animating view after applying frames to views

        guard let animatingView = sourceTransition?.zoomTransitionAnimatingView else { return }

        let animatingFrame = containerView.convert(animatingView.frame, from: fromView)
        animatingView.transform = fromView.transform
        animatingView.frame = animatingFrame
        containerView.addSubview(animatingView)

        sourceTransition?.zoomTransitionHideViews(hide: true)
        destinationTransition?.zoomTransitionHideViews(hide: true)

        fromView.alpha = 1
        toView.alpha = 0

        interactiveTransitionContext = InteractiveTransitionContext(
            transitionContext: transitionContext,
            fromViewController: fromVC,
            toViewController: toVC,
            fromView: fromView,
            toView: toView,
            animatingView: animatingView,
            animatingViewInitialPosition: animatingView.center,
            progress: 0,
            progressDistance: containerView.bounds.height / 2
        )

        // Complete the transition if gesture is currently ended
        if isEnded {
            if !shouldComplete {
                cancel()
            } else {
                finish()
            }
        }
    }

    open func update(progress: CGFloat, translation: CGPoint) {
        guard isFullInteractive else {
            updateSemiInteractiveTransition(progress: progress, translation: translation)
            return
        }

        guard var context = interactiveTransitionContext else { return }

        let center = CGPoint(
            x: context.animatingViewInitialPosition.x + translation.x,
            y: context.animatingViewInitialPosition.y + translation.y
        )
        context.animatingView.center = center

        context.fromView.alpha = 1 - progress
        context.toView.alpha = progress

        context.progress = progress
        context.transitionContext.updateInteractiveTransition(progress)

        self.interactiveTransitionContext = context
    }

    open func finish() {
        guard isFullInteractive else {
            finishSemiInteractiveTransition()
            return
        }

        guard let context = interactiveTransitionContext else { return }

        let toFinalFrame = context.transitionContext.finalFrame(for: context.toViewController)
        let destinationFrame = destinationTransition?.zoomTransitionDestinationFrame(for: context.animatingView, frame: toFinalFrame)

        animationSetup?(context.animatingView)

        context.transitionContext.finishInteractiveTransition()

        UIView.animate(withDuration: zoomDuration, delay: 0, options: [ .curveEaseOut ],
            animations: {
                context.animatingView.transform = .identity

                if let destinationFrame = destinationFrame {
                    context.animatingView.frame = destinationFrame
                }

                context.fromView.alpha = 0
                context.toView.alpha = 1

                self.animation?(context.animatingView, self.zoomDuration)
            },
            completion: { _ in
                self.sourceTransition?.zoomTransitionHideViews(hide: false)
                self.destinationTransition?.zoomTransitionHideViews(hide: false)

                context.transitionContext.completeTransition(!context.transitionContext.transitionWasCancelled)
            }
        )
    }

    open func cancel() {
        guard isFullInteractive else {
            cancelSemiInteractiveTransition()
            return
        }

        guard let context = interactiveTransitionContext else { return }

        let duration = minimumZoomDuration + (zoomDuration - minimumZoomDuration) * TimeInterval(context.progress)

        context.transitionContext.cancelInteractiveTransition()

        UIView.animate(withDuration: duration, delay: 0, options: [ .curveEaseOut ],
            animations: {
                context.animatingView.center = context.animatingViewInitialPosition

                context.fromView.alpha = 1
                context.toView.alpha = 0
            },
            completion: { _ in
                self.sourceTransition?.zoomTransitionHideViews(hide: false)
                self.destinationTransition?.zoomTransitionHideViews(hide: false)

                context.transitionContext.completeTransition(!context.transitionContext.transitionWasCancelled)
            }
        )
    }

    // MARK: - Semi interactive transition

    private struct SemiInteractiveTransitionContext {
        let fromView: UIView

        var animatingView: UIView
        var animatingViewInitialPosition: CGPoint = .zero

        var progress: CGFloat = 0
        var progressDistance: CGFloat = 0
    }

    private var semiInteractiveTransitionContext: SemiInteractiveTransitionContext?

    private func startSemiInteractiveTransition() {
        guard
            let fromView = sourceRootView?(),
            let animatingView = sourceTransition?.zoomTransitionAnimatingView
        else { return }

        fromView.addSubview(animatingView)

        sourceTransition?.zoomTransitionHideViews(hide: true)

        semiInteractiveTransitionContext = SemiInteractiveTransitionContext(
            fromView: fromView,
            animatingView: animatingView,
            animatingViewInitialPosition: animatingView.center,
            progress: 0,
            progressDistance: fromView.bounds.height / 2
        )
    }

    private func updateSemiInteractiveTransition(progress: CGFloat, translation: CGPoint) {
        guard var semiContext = semiInteractiveTransitionContext else { return }

        let center = CGPoint(
            x: semiContext.animatingViewInitialPosition.x + translation.x,
            y: semiContext.animatingViewInitialPosition.y + translation.y
        )
        semiContext.animatingView.center = center

        semiContext.progress = progress

        self.semiInteractiveTransitionContext = semiContext
    }

    private func finishSemiInteractiveTransition() {
        guard semiInteractiveTransitionContext != nil else { return }

        interactive = false

        startTransition?()
    }

    private func cancelSemiInteractiveTransition() {
        guard let semiContext = semiInteractiveTransitionContext else { return }

        let duration = minimumZoomDuration + (zoomDuration - minimumZoomDuration) * TimeInterval(semiContext.progress)

        UIView.animate(withDuration: duration, delay: 0, options: [ .curveEaseOut ],
            animations: {
                semiContext.animatingView.center = semiContext.animatingViewInitialPosition
            },
            completion: { _ in
                self.sourceTransition?.zoomTransitionHideViews(hide: false)
                self.destinationTransition?.zoomTransitionHideViews(hide: false)

                self.animationEnded(false)
            }
        )
    }

    // MARK: - Pan gesture

    private var shouldComplete: Bool = false
    private var isEnded: Bool = false
    private var isFullInteractive: Bool = true

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGestureRecognizer else { return true }

        // Only vertical swipes
        let velocity = panGestureRecognizer.velocity(in: nil)
        return abs(velocity.y) > abs(velocity.x)
    }

    @objc private func panGestureAction(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)

        switch gestureRecognizer.state {
            case .began:
                isEnded = false

                isFullInteractive = shouldStartInteractiveTransition?() ?? true

                if isFullInteractive {
                    startTransition?()
                } else {
                    startSemiInteractiveTransition()
                }
            case .changed:
                guard
                    let progressDistance = interactiveTransitionContext?.progressDistance
                        ?? semiInteractiveTransitionContext?.progressDistance
                else { return }

                var progress = abs(translation.y) / progressDistance
                progress = min(progress, 1.0)

                shouldComplete = progress > 0.5 || abs(velocity.y) > 700.0

                update(progress: progress, translation: translation)
            case .cancelled:
                isEnded = true

                if !shouldComplete {
                    cancel()
                } else {
                    finish()
                }
            case .ended:
                isEnded = true

                if !shouldComplete {
                    cancel()
                } else {
                    finish()
                }
            default:
                break
        }
    }
}
