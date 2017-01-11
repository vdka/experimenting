
import UIKit

protocol FlowController {
    static func from(storyboard: Storyboard) -> Self
}

fileprivate func firstTransform() -> CATransform3D {
    var t1 = CATransform3DIdentity
    t1.m34 = 1.0 / -900
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1)
    t1 = CATransform3DRotate(t1, 15.0 * .pi / 180.0, 1, 0, 0)
    return t1
}

fileprivate func secondTransformWithView(view: UIView) -> CATransform3D {
    var t2 = CATransform3DIdentity
    t2.m34 = firstTransform().m34
    t2 = CATransform3DTranslate(t2, 0, view.frame.size.height * -0.08, 0)
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1)
    return t2
}

extension FlowController where Self: UIViewController {

    @discardableResult
    static func makeRootViewController(from storyboard: Storyboard) -> Self {

        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { fatalError() }
        guard let snapshot = window.snapshotView(afterScreenUpdates: true) else { fatalError() } // NOTE(vdka): The docs do not mention where this may be nil.

        for view in window.subviews { view.removeFromSuperview() }
        window.rootViewController = nil
        let newRootViewController = Self.from(storyboard: storyboard)

        window.rootViewController = newRootViewController

        window.addSubview(snapshot)


        // MARK: Animation

        let toView = newRootViewController.view!
        let fromView = snapshot

        let frame = fromView.frame
        toView.frame = frame
        let scale = CATransform3DIdentity
        toView.layer.transform = CATransform3DScale(scale, 0.6, 0.6, 1)
        toView.alpha = 0.6

        window.insertSubview(toView, belowSubview: fromView)
        var frameOffScreen = frame
        frameOffScreen.origin.y = frame.height
        let t1 = firstTransform()

        UIView.animateKeyframes(withDuration: 0.75, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                fromView.frame = frameOffScreen
            }

            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.35) {
                toView.layer.transform = t1
                toView.alpha = 1.0
            }

            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                toView.layer.transform = CATransform3DIdentity
            }

        }, completion: { _ in
            fromView.removeFromSuperview()
        })
        
        return newRootViewController
    }
}
