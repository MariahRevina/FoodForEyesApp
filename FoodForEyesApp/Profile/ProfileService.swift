import Foundation

struct ProfileResult: Codable{
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = [profileResult.firstName, profileResult.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private(set) var profile: Profile?
    
    private init() {}
    
    private func profileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me")
        else {return nil}
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = profileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>)  in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                let profile = Profile(from: profile)
                self.profile = profile
                
                completion(.success(profile))
                
            case .failure(let error):
                print ("Unsuccessful decoding because of: \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func clearProfile() {
        profile = nil
    }
}
