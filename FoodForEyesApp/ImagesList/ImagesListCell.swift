import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!

    static var reuseIdentifier = "ImagesListCell"
}
