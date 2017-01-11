
import UIKit
import Kingfisher

class ImageCell: UITableViewCell {

    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var timeSince: UILabel!
    @IBOutlet weak var photographer: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var loadingView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func set(image: Unsplash.Image) {
        self.likes.text = image.likes.description + " Likes"
        self.timeSince.text = image.uploadedAt.format(relativeTo: Date())
        self.photographer.text = image.photographer.name
        self.photo.kf.setImage(with: image.smallUrl, progressBlock: nil) { [weak self] (_, _, _, _) in
            self?.loadingView.isHidden = true
        }
    }
}
