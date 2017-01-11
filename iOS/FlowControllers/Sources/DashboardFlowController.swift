
import UIKit

final class DashboardFlowController: UINavigationController, FlowController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        URLCache.shared = urlCache

        let dashboardViewController = (self.topViewController as? DashboardViewController)

        dashboardViewController?.logout = {
            LoginFlowController.makeRootViewController(from: .login)
        }

        dashboardViewController?.onSelect = { [unowned self] image, placeholder in

            let detailViewController = DashboardDetailViewController.from(storyboard: .dashboard)

            self.present(detailViewController, animated: true)
            detailViewController.image = image
            detailViewController.placeholder = placeholder

            detailViewController.onUserSelect = { [unowned self, dashboardViewController] user in
                dashboardViewController?.filter = .user(user)
                self.dismiss(animated: true)
            }

            detailViewController.close = { [unowned self] in
                self.dismiss(animated: true)
            }

            detailViewController.logout = {
                LoginFlowController.makeRootViewController(from: .login)
            }
        }
    }
}
