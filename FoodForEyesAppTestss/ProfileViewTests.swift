import XCTest
@testable import FoodForEyesApp
// MARK: - Test Doubles

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var didTapLogoutButtonCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func updateProfileDetails() {
        updateProfileCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func performLogout() {}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var displayedName: String?
    var displayedLoginName: String?
    var displayedBio: String?
    var displayedAvatarURL: URL?
    var displayedPlaceholder: UIImage?
    var showLogoutConfirmationCalled = false
    
    func displayProfileDetails(name: String, loginName: String, bio: String?) {
        displayedName = name
        displayedLoginName = loginName
        displayedBio = bio
    }
    
    func displayAvatar(with url: URL?, placeholder: UIImage?) {
        displayedAvatarURL = url
        displayedPlaceholder = placeholder
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }
}

// MARK: - Tests

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled, "При загрузке экрана должен вызываться viewDidLoad у презентера")
    }
    
    func testPresenterUpdatesProfileAndAvatar() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.updateProfileDetails()
        presenter.updateAvatar()
        
        // then
        XCTAssertNotNil(viewController.displayedName, "Должны обновляться данные профиля")
        XCTAssertNotNil(viewController.displayedAvatarURL, "Должен обновляться аватар")
    }
    
    func testDidTapLogoutButtonCallsShowLogoutAlert() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewController
        
        // when
        presenter.didTapLogoutButton()
        
        // then
        XCTAssertTrue(viewController.showLogoutConfirmationCalled, "При нажатии кнопки выхода должно показываться подтверждение")
    }
}
