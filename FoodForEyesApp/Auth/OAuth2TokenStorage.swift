import Foundation

final class OAuth2TokenStorage{
    static let shared = OAuth2TokenStorage()
    private let accessToken = "accessToken"
    
    private init() {}
    
    var token: String? {
        get{UserDefaults.standard.string(forKey: accessToken)}
        set{UserDefaults.standard.set(newValue, forKey: accessToken)}
    }
}
