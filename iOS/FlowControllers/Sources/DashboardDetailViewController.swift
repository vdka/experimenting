
import UIKit

import Hue
import Kingfisher

class DashboardDetailViewController: UIViewController {

    var image: Unsplash.Image!
    var placeholder: UIImage?

    var onUserSelect: ((Unsplash.User) -> Void)?
    var close: ((Void) -> Void)?
    var logout: ((Void) -> Void)?

    @IBOutlet weak var photographer: UIButton!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var closeButton: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()

        self.photographer.setTitle("By " + image.photographer.name, for: .normal)
        self.likes.text = image.likes.description + " Likes"
        self.createdAt.text = image.uploadedAt.format(relativeTo: Date())

        self.imageView.kf.setImage(
            with: image.customUrl,
            placeholder: placeholder?.kf.blurred(withRadius: 2),
            options: [.transition(.fade(1.0))],
            progressBlock: { [weak self] done, total in

                let amount = Float(done) / Float(total)
                self?.progress.setProgress(amount, animated: true)
                if amount >= 0.95 {
                    UIView.animate(withDuration: 1.0) {
                        self?.progress.alpha = 0.0
                    }
                }
            }, completionHandler: { [weak self] _ in
                self?.progress.isHidden = true
            }
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)

        ImageCache.default.removeImage(forKey: image.customUrl.absoluteString, fromDisk: false)
    }

    @IBAction func didPressPhotographer() {
        self.onUserSelect?(image.photographer)
    }

    @IBAction func didPressClose() {
        self.close?()
    }

    @IBAction func didPressLogout() {
        self.logout?()
    }
}
