import UIKit

final class ImagesListViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet private var tableView: UITableView!

    // MARK: - Properties

    let showSingleImageSegueIdentifier = "ShowSingleImage"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
