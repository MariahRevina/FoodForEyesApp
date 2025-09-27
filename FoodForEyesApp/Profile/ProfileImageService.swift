import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    
    private var task: URLSessionTask?
    
    private(set) var avatarURL: String?
    
    private init () {}
    
    private func imageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)")
        else {return nil}
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        guard let request = imageRequest(username: username,token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>)  in
            
            switch result {
                
            case .success(let imageURL):
                guard let self = self else { return }
                self.avatarURL = imageURL.profileImage.small
                completion( .success(imageURL.profileImage.small))
                
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": self.avatarURL ?? ""])
                
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    func cleanAvatarURL() {
            avatarURL = nil
        }
}

