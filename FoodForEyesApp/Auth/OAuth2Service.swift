import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private init() {
        
    }
    
    func authTokenRequest(code: String) -> URLRequest? {
        
        let baseURL = "https://unsplash.com/oauth/token"
        
        guard var urlComponents = URLComponents(string: baseURL) else {
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
        request.httpMethod = "POST"
        return request
    }
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = authTokenRequest(code: code) else {
            print("Ошибка: Невозможно создать запрос - \(NetworkError.invalidRequest)")
            DispatchQueue.main.async{
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage.shared.token = response.accessToken
                    print("Токен получен и сохранен")
                    completion(.success(response.accessToken))
                    
                } catch let decodingError {
                    print("Ошибка декодирования токена: \(decodingError)")
                    completion(.failure(NetworkError.decodingError(decodingError)))
                }
            case .failure(let error):
                print("Сетевая ошибка при получении токена: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
