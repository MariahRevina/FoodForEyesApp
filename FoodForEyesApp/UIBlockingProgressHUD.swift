import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    public static var window: UIWindow?{
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
