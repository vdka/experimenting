
import UIKit

extension Improvements where Base: UITextField {

    var text: String {
        return base.text ?? ""
    }
}
