import UIKit

final class ImagesListCell: UITableViewCell {

    // MARK: - Constants

    static let reuseIdentifier = "ImagesListCell"

    // MARK: - IB Outlets

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    // MARK: - Methods

    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
