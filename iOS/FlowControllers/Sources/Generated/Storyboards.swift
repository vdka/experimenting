// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

enum Storyboard: String {
    case dashboard = "Dashboard"
    case launchScreen = "LaunchScreen"
    case login = "Login"

    var storyboard: UIStoryboard {
      return UIStoryboard(name: rawValue, bundle: nil)
    }
}


extension DashboardDetailViewController {

  static func from(storyboard: Storyboard) -> DashboardDetailViewController {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil)
      .instantiateViewController(withIdentifier: "DashboardDetailViewController") as! DashboardDetailViewController
  }
}

extension DashboardFlowController {

  static func from(storyboard: Storyboard) -> DashboardFlowController {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil)
      .instantiateViewController(withIdentifier: "DashboardFlowController") as! DashboardFlowController
  }
}

extension LoginFlowController {

  static func from(storyboard: Storyboard) -> LoginFlowController {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil)
      .instantiateViewController(withIdentifier: "LoginFlowController") as! LoginFlowController
  }
}

extension LoginViewController {

  static func from(storyboard: Storyboard) -> LoginViewController {
    return UIStoryboard(name: storyboard.rawValue, bundle: nil)
      .instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
  }
}

