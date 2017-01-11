
import UIKit

protocol KeyboardAvoiding: KeyboardObserver {
    var keyboardOffsetConstraint: NSLayoutConstraint! { get set }
}

extension KeyboardAvoiding where Self: UIViewController {

    func beginAvoidingKeyboard(additionalAnimations extra: ((KeyboardState) -> Void)? = nil) {

        self.observeKeyboard { [weak self] state in

            guard let `self` = self else { return }

            self.keyboardOffsetConstraint.constant = state.visible ? state.frameEnd.height : 0

            let animationOption = UIViewAnimationOptions(rawValue: UInt(state.animationCurve))
            UIView.animate(withDuration: state.animationDuration, delay: 0, options: animationOption, animations: {

                extra?(state)
                self.view.layoutIfNeeded()
            })
        }
    }
}
