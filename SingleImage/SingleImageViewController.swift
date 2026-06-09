import UIKit

final class SingleImageViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!

    // MARK: - Properties

    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }

    // MARK: - IB Actions

    @IBAction func didTapShareButton() {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Methods

    func centerImageInScrollView() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let topInset = max((scrollViewSize.height - contentSize.height) / 2, 0)
        let leftInset = max((scrollViewSize.width - contentSize.width) / 2, 0)

        scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: 0, right: 0)
    }

    // MARK: - Private Methods

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        centerImageInScrollView()
    }
}
