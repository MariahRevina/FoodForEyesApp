import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet  private var dateLabel: UILabel!
    @IBOutlet  private var cellImage: UIImageView!
    @IBOutlet  private var likeButton: UIButton!

    static var reuseIdentifier = "ImagesListCell"
    
    func configure(with image: UIImage?, date: String, isLiked: Bool) {
        cellImage.image = image
        dateLabel.text = date
        let imageInLikeButton = isLiked ? UIImage(named: "Active") : UIImage(named: "Passive")
        likeButton.setImage(imageInLikeButton, for: .normal)
    }
}
