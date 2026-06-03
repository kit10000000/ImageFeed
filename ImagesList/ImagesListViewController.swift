import UIKit

final class ImagesListViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties

    let photosName: [String] = Array(0..<20).map { "\($0)" }

    // MARK: - Private Properties

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    // MARK: - Methods

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName: String = photosName[indexPath.row]
        let isLiked: Bool = ((indexPath.row % 2) != 1) ? true : false

        guard let image = UIImage(named: imageName) else { return }
        cell.imageCell.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        cell.setIsLiked(isLiked)
    }
}
