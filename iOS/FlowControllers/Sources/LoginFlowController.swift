
import UIKit

final class LoginFlowController: UINavigationController, FlowController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        guard let loginViewController = (self.topViewController as? LoginViewController) else { fatalError("Expected the topViewController in LoginFlow to be a LoginViewController") }

        loginViewController.login = { auth in
            Unsplash.Authorization.current = auth
            DashboardFlowController.makeRootViewController(from: .dashboard)
        }
    }
}
