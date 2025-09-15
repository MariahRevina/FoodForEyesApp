import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var userAvatar = UIImageView()
    
    private let logoutButton = UIButton()
    
    private var userNameLabel = UILabel()
    
    private var loginNameLabel = UILabel()
    
    private var descriptionLabel = UILabel()
    
    private let profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        setupUserAvatar()
        
        setupLogoutButton()
        setupUserNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupConstraints()
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    private func updateAvatar() {
        print("updateAvatar called")
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            print("No avatar URL available")
            return }
        
        print("Loading avatar from imageUrl: \(url)")
        
        let placeholder = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        userAvatar.kf.indicatorType = .activity
        userAvatar.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { result in
            switch result {
            case .success(let value):
                print(value.image)
                print(value.cacheType)
                print(value.source)
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    
    private func updateProfileDetails(profile: Profile) {
        
        userNameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        loginNameLabel.text = profile.loginName.isEmpty
        ? "Логин не указан"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
        
    }
    
    private func addSubview(_ view: UIView, to parentview: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentview.addSubview(view)
    }
    
    private func setupUserAvatar() {
        userAvatar.layer.cornerRadius = 35
        addSubview(userAvatar, to: view)
    }
    
    private func setupLogoutButton () {
        
        logoutButton.setImage(UIImage(named:"Exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        addSubview(logoutButton, to: view)
        
    }
    
    private func setupUserNameLabel() {
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        addSubview(userNameLabel, to: view)
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        addSubview(loginNameLabel, to: view)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        addSubview(descriptionLabel, to: view)
    }
    
    @objc private func didTapLogoutButton() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.clearProfile()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            userAvatar.heightAnchor.constraint(equalToConstant: 70),
            userAvatar.widthAnchor.constraint(equalTo: userAvatar.heightAnchor),
            userAvatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            userAvatar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalTo: logoutButton.heightAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: userAvatar.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            userNameLabel.topAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatar.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: userAvatar.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: userAvatar.leadingAnchor)
        ])
    }
    
}
