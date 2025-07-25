import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var avatarImage: UIImageView!
    
    @IBOutlet private var logoutButton: UIButton!
    @IBOutlet private var helloWorldLabel: UILabel!
    @IBOutlet private var userLoginLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func didTapLogoutButton() {
    }
    
}
