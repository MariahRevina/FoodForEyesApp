import Foundation
import WebKit

import Foundation

protocol ProfileLogoutServiceProtocol {
    func logout()
}

extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

final class ProfileLogoutService{
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        resetAllServices()
        cleanCookies()
        switchToAuthScreen()
    }
    
    private func resetAllServices() {
        
        OAuth2TokenStorage.shared.token = nil
        
        ProfileService.shared.clearProfile()
        
        ProfileImageService.shared.cleanAvatarURL()
        
        ImagesListService.shared.cleanImages()
    }
    func cleanCookies() {
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToAuthScreen() {
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let splashViewController = SplashViewController()
            window.rootViewController = splashViewController
            
        }
    }
}
