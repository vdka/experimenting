
import UIKit

final class LoginViewController: UIViewController, KeyboardAvoiding {

    var login: ((Unsplash.Authorization) -> Void)?

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var keyboardOffsetConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.beginAvoidingKeyboard()

        self.usernameTextfield.text = "vdka"
        self.passwordTextfield.text = "genericPassword"
    }

    @IBAction func didPressLogin() {
        guard !usernameTextfield.imp.text.isEmpty, !passwordTextfield.imp.text.isEmpty else { return }

        login?(.none)
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTextfield {
            passwordTextfield.becomeFirstResponder()
        } else if textField === passwordTextfield {
            guard !usernameTextfield.imp.text.isEmpty, !passwordTextfield.imp.text.isEmpty else { return false }
            login?(.none)
        }

        return true
    }
}
