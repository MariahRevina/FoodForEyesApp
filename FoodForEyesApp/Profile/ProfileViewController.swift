import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func displayProfileDetails(name: String, loginName: String, bio: String?)
    func displayAvatar(with url: URL?, placeholder: UIImage?)
    func showLogoutConfirmation()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - UI Elements
    private var userAvatar = UIImageView()
    private let logoutButton = UIButton()
    private var userNameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    
    // MARK: - Properties
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
                    setupPresenter()
                }
        setupUI()
        setupConstraints()
        setupAccessibilityIdentifiers()
        presenter?.viewDidLoad()
    }
    
    
    // MARK: - Configuration
    
    func configure(_ presenter: ProfilePresenterProtocol) {
            self.presenter = presenter
            self.presenter?.view = self
        }
    
    // MARK: - Setup
    private func setupPresenter() {
        let presenter = ProfilePresenter()
        presenter.view = self
        self.presenter = presenter
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        setupUserAvatar()
        setupLogoutButton()
        setupUserNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
    }
    
    private func setupUserAvatar() {
        userAvatar.layer.cornerRadius = 35
        userAvatar.clipsToBounds = true
        addSubview(userAvatar, to: view)
    }
    
    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "Exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.accessibilityIdentifier = "logoutButton"
        addSubview(logoutButton, to: view)
    }
    
    private func setupUserNameLabel() {
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        addSubview(userNameLabel, to: view)
    }
    
    private func setupLoginNameLabel() {
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(named: "YP Gray (iOS)")
        addSubview(loginNameLabel, to: view)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)")
        addSubview(descriptionLabel, to: view)
    }
    
    // MARK: - ProfileViewControllerProtocol
    func displayProfileDetails(name: String, loginName: String, bio: String?) {
        userNameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func displayAvatar(with url: URL?, placeholder: UIImage?) {
        guard let url = url else {
            userAvatar.image = placeholder
            return
        }
        
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
                print("Avatar loaded successfully: \(value.source)")
            case .failure(let error):
                print("Avatar loading failed: \(error)")
            }
        }
    }
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.performLogout()
        })
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        presenter?.didTapLogoutButton()
    }
    
    // MARK: - Helper Methods
    private func addSubview(_ view: UIView, to parentView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
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
    
    private func setupAccessibilityIdentifiers() {
        userNameLabel.accessibilityIdentifier = "userNameLabel"
        loginNameLabel.accessibilityIdentifier = "loginNameLabel"
        descriptionLabel.accessibilityIdentifier = "descriptionLabel"
    }
}
