import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage{
    static let shared = OAuth2TokenStorage()
    private let accessToken = "accessToken"
    
    private init() {}
    
    var token: String? {
        get{return KeychainWrapper.standard.string(forKey: accessToken)}
        set{
            if let token = newValue{
                KeychainWrapper.standard.set(token, forKey: accessToken)
            } else {
                KeychainWrapper.standard.removeObject(forKey: accessToken)
            }
        }
    }
}
