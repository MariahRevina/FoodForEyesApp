import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private var splashScreenLogo = UIImageView(image: UIImage(named: "VectorLaunchscreen"))
    
    private let storage = OAuth2TokenStorage.shared
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI ()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("storage.token: \(storage.token ?? "nil")")
        
        ProgressHUD.animate()
        if let token = storage.token {
            
            fetchProfile(token: token)
        } else {
            ProgressHUD.dismiss()
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupUI () {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        
        splashScreenLogo.contentMode = .scaleAspectFit
        splashScreenLogo.clipsToBounds = true
        splashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(splashScreenLogo)
        
        NSLayoutConstraint.activate([
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenLogo.widthAnchor.constraint(equalToConstant: 74),
            splashScreenLogo.heightAnchor.constraint(equalToConstant: 76.64)
        ])
    }
    
    private func presentAuthViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure( "Не удалось создать экземпляр AuthViewController по идентификатору")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
        
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate{
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        print("5. Делегат вызван с токеном: \(token)")
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        print("6. Токен в storage после сохранения: \(storage.token ?? "nil")")
        fetchProfile(token: token)
    }
    
    private func fetchProfile (token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case let .success (profile):
                
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
                
            case .failure(let error):
                print("Профиля нет, потому что \(error)")
                break
            }
        }
    }
}
