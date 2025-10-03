import UIKit
import Kingfisher

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func updateProfileDetails()
    func updateAvatar()
    func performLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private let notificationCenter: NotificationCenter
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared,
        notificationCenter: NotificationCenter = .default
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
        self.notificationCenter = notificationCenter
    }
    
    func viewDidLoad() {
        setupObservers()
        updateProfileDetails()
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutConfirmation()
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let loginName = profile.loginName.isEmpty ? "Логин не указан" : profile.loginName
        let bio: String? = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
        
        view?.displayProfileDetails(name: name, loginName: loginName, bio: bio)
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else {
            return
        }
        
        let placeholder = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        view?.displayAvatar(with: url, placeholder: placeholder)
    }
    
    func performLogout() {
        logoutService.logout()
    }
    
    private func setupObservers() {
        profileImageServiceObserver = notificationCenter.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            notificationCenter.removeObserver(observer)
        }
    }
}
