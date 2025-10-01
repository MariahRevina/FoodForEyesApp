import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
    func willDisplayCell(at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var photosCount: Int {
        return photos.count
    }
    
    func viewDidLoad() {
        setupNotifications()
        imagesListService.fetchPhotosNextPage()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let updatedIndexPath = notification.userInfo?["updatedIndexPath"] as? IndexPath {
                self?.updateTableViewAnimated(updatedIndexPath: updatedIndexPath)
            } else {
                self?.updateTableViewAnimated()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ImageLoaded"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let indexPath = notification.userInfo?["IndexPath"] as? IndexPath {
                self?.view?.reloadRow(at: indexPath)
            }
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        let dateString = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.configure(with: photo, date: dateString)
    }
    
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        view?.showSingleImage(for: indexPath)
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = view?.getIndexPath(for: cell),
              indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.view?.showLikeErrorAlert(error: error)
                }
            }
        }
    }
    
    private func updateTableViewAnimated(updatedIndexPath: IndexPath? = nil) {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if let updatedIndexPath = updatedIndexPath {
            view?.reloadRow(at: updatedIndexPath)
        } else if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            view?.insertRows(at: indexPaths)
        } else {
            view?.reloadTableView()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
