import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Public Properties
    
    var photo: Photo? {
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
        
        if let photo = photo {
            imageView.frame.size = photo.size
        }
        updateImage()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
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

        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width > 0 && imageSize.height > 0 else {return}
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(scrollView.minimumZoomScale, min(scrollView.maximumZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x:x, y:y), animated: false)
    }
    
    private func updateImage() {
        guard let photo = photo, let url = URL(string: photo.largeImageURL) else { return }
        imageView.kf.indicatorType = .activity
        imageView.frame.size = photo.size
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "singleImageStub"),
            options: [.transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Downloading image failed with error: \(error)")
                self.showAlert ()
            }
        }
    }
    
    private func showAlert () {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "Повторить?", style: .default) {[weak self] _ in
            self?.updateImage()
        }
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
