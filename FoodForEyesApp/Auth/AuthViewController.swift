import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    private let segueMeaning = "ShowWebView"
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        print("AuthViewController загружен")
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare called for segue: \(segue.identifier ?? "nil")")
        if segue.identifier == segueMeaning {
            print("Идентификатор segue: \(segue.identifier ?? "nil")")
            print("Ожидаемый идентификатор: \(segueMeaning)")
            guard let webViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(segueMeaning)")
                return
            }
            print("Тип destination: \(type(of: segue.destination))")
            print("Is WebViewViewController: \(segue.destination is WebViewViewController)")
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        print("1. Получен код: \(code)")
        UIBlockingProgressHUD.show()
            oauth2Service.fetchOAuthToken(code) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let token):
                    print("2. Успешно получили токен: \(token)")
                    self.storage.token = token
                    print("3. Сохранили в storage: \(self.storage.token ?? "nil")")
                    vc.dismiss(animated: true)
                    print("4. WebView закрыт, вызываем делегат")
                    self.delegate?.didAuthenticate(self, didAuthenticateWithToken: token)
                    
                    
                case .failure(let error):
                    print("4. Ошибка получения токена: \(error)")
                    showAlert(title: "Что-то пошло не так", message: "Не удалось войти в систему")
                }
            }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if Thread.isMainThread {
            present(alert, animated: true)
        } else {
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
}
