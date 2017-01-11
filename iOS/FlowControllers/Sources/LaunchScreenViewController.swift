
import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let login = LoginViewController.from(storyboard: .login)
        self.present(login, animated: true, completion: nil)
    }
}
