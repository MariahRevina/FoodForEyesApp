import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case requestInProgress
    case alreadyHaveToken
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastcode: String?
    private var dataStorage = OAuth2TokenStorage.shared
    
    private(set) var authToken: String? {
        get {return dataStorage.token}
        set {dataStorage.token = newValue}
    }
    
    private init() {
        
    }
    
    func authTokenRequest(code: String) -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Невозможно создать объект URLComponents из строки")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            print("Ошибка: Неверная структура URL-компонентов для формирования URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastcode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.requestInProgress))
                return
            }
        } else {
            if lastcode == code {
                completion(.failure(AuthServiceError.alreadyHaveToken))
                return
            }
        }
        lastcode = code
        guard let request = authTokenRequest(code: code) else {
            print("Ошибка: Невозможно создать запрос - \(NetworkError.invalidRequest)")
            DispatchQueue.main.async{
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        UIBlockingProgressHUD.show()
        
        let task = urlSession.objectTask(for: request) { [weak self]  (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                
                switch result {
                case .success(let body):
                    let authtoken = body.accessToken
                    self.authToken = authtoken
                    completion(.success(authtoken))
                    
                    self.task = nil
                    self.lastcode = nil
                    
                case .failure(let error):
                    print("[fetchOAuthToken]: Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                    
                    self.task = nil
                    self.lastcode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}
