import UIKit

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            updateImage()
        }
    }
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        updateImage()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
            )
            present(share, animated: true, completion: nil)
    }
    
    // MARK: - Delegates
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageAfterZoom()
    }
    
    // MARK: - Private Methods
    private func centerImageAfterZoom() {
        guard let image = imageView.image else { return }
        let boundsSize = scrollView.bounds.size
        let imageSize = image.size
        let hInsets = max((boundsSize.width - imageSize.width * scrollView.zoomScale)/2,0)
        let yInsets = max((boundsSize.height - imageSize.height * scrollView.zoomScale)/2,0)
        scrollView.contentInset = UIEdgeInsets(top: yInsets, left: hInsets, bottom: yInsets, right: hInsets)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        //let minZoomScale = scrollView.minimumZoomScale
        //let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        //let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        let scale = max(scrollView.minimumZoomScale, min(scrollView.maximumZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x:x, y:y), animated: false)
    }
    
    private func updateImage() {
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
}
