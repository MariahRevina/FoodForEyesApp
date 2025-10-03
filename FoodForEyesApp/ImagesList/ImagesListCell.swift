import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet  private var dateLabel: UILabel!
    @IBOutlet  private var cellImage: UIImageView!
    @IBOutlet  private var likeButton: UIButton!

    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
            delegate?.imageListCellDidTapLike(self)
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.kf.indicatorType = .activity
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    func configure(with photo: Photo, date: String) {
        dateLabel.text = date
        setIsLiked(photo.isLiked)
        
        if let url = URL(string: photo.thumbImageURL) {
            
            let placeHolder = UIImage(named: "loadingImageStub")
            
            cellImage.kf.setImage(
                with: url,
                placeholder: placeHolder,
                options:[
                    .transition(.fade(0.2))
                ]
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ImageLoaded"),
                        object: self,
                        userInfo: ["IndexPath": IndexPath(row: self.tag, section: 0)])
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
                
            }
            
        }
        
    }
    private func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "Active" : "Passive"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "Active" : "Passive"
    }
}
