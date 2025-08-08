import UIKit

final class ProfileViewController: UIViewController {
    
    let userAvatar = UIImageView(image: UIImage(named: "Photo") ?? UIImage(systemName: "person.crop.circle.fill"))
    
    private let logoutButton = UIButton()
    
    private let userNameLabel = UILabel()
    
    private let loginNameLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserAvatar()
        setupLogoutButton()
        setupUserNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupConstraints()
        
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
