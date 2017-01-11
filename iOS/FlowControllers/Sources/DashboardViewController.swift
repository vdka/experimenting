
import UIKit

import JSON
import Kingfisher

final class DashboardViewController: UIViewController {

    var logout: ((Void) -> Void)?
    var onSelect: ((Unsplash.Image, UIImage?) -> Void)?

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewLabel: UILabel!

    enum Filter {
        case user(Unsplash.User)
        case none
    }

    var filter: Filter = .none {
        didSet {
            self.photos = []
            guard self.view != nil else { return } // ensures iboutlets are established.
            self.update()
        }
    }

    var photos: [Unsplash.Image] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let photoNib = UINib(nibName: "ImageCell", bundle: nil)
        tableView.register(photoNib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 377

        self.filter = .none // trigger the didSet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        ImageCache.default.clearMemoryCache()
    }

    func update() {

        let updateContents: (JSON?) -> Void = { [weak self] json in
            DispatchQueue.main.sync {
                defer { self?.tableView.reloadData() }
                guard let json = json, let `self` = self else { return }
                self.loadingView.isHidden = true

                self.photos = []
                do {
                    self.photos = try json.get()

                    self.loadingView.isHidden = !self.photos.isEmpty
                    if self.photos.isEmpty {
                        self.loadingViewLabel.text = "Nothing Here!"
                    }
                } catch {
                    print(error)
                }
            }
        }

        self.loadingView.isHidden = false
        self.loadingViewLabel.text = "Loading"

        switch filter {
        case .user(let user):
            self.logoutButton.setTitle("Clear Filter", for: .normal)
            Unsplash.userPhotos(username: user.username, count: 50, completion: updateContents)

        case .none:
            self.logoutButton.setTitle("Logout", for: .normal)
            Unsplash.random(count: 50, completion: updateContents)
        }
    }

    @IBAction func didPressLogout() {
        if case .none = filter {
            logout?()
        } else {
            filter = .none
        }
    }
}

extension DashboardViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let untypedCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let cell = untypedCell as? ImageCell else { print("cell wrong type"); return untypedCell }
        let image = photos[indexPath.row]

        cell.set(image: image)

        return cell
    }
}

extension DashboardViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let image = self.photos[indexPath.row]
        let cell = (tableView.cellForRow(at: indexPath) as? ImageCell)

        self.onSelect?(image, cell?.photo.image)
    }
}

extension DashboardViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap { self.photos[$0.row].smallUrl }
        ImagePrefetcher(urls: urls).start()
    }
}
