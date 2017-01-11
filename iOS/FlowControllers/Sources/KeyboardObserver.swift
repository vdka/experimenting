
import UIKit

public struct KeyboardState {
    public var frameBegin: CGRect
    public var frameEnd: CGRect
    public var animationCurve: Int
    public var animationDuration: Double
    public var localUser: Bool
    public var visible: Bool

    internal init?(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frameBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let localUser = userInfo[UIKeyboardIsLocalUserInfoKey] as? Bool
            else { return nil }

        self.frameBegin = frameBegin
        self.frameEnd = frameEnd
        self.animationCurve = animationCurve
        self.animationDuration = animationDuration
        self.localUser = localUser
        self.visible = self.frameEnd.origin.y != UIScreen.main.bounds.height
    }
}

extension KeyboardState: Equatable {}

public func == (lhs: KeyboardState, rhs: KeyboardState) -> Bool {
    return
        lhs.visible == rhs.visible &&
        lhs.frameBegin == rhs.frameBegin &&
        lhs.frameEnd == rhs.frameEnd &&
        lhs.animationCurve == rhs.animationCurve &&
        lhs.animationDuration == rhs.animationDuration &&
        lhs.localUser == rhs.localUser
}

public protocol KeyboardObserver {}

extension KeyboardObserver where Self: UIViewController {

    // On iOS9 NSNotificationCenter observers are stored in a way that does not need to be removed.
    public func observeKeyboard(_ closure: @escaping ((KeyboardState) -> Void)) {

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { notification in

            guard let keyboardState = KeyboardState(notification: notification) else { return }
            closure(keyboardState)
        }
    }
}
