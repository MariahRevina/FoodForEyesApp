import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText("")
        
        webView.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        
        UIPasteboard.general.string = ""
        passwordTextField.press(forDuration: 1.1)
        
        let pasteButton = app.menuItems["Paste"]
        XCTAssertTrue(pasteButton.waitForExistence(timeout: 5))
        pasteButton.tap()
        
        webView.tap()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["Passive"].tap()
        cellToLike.buttons["Active"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Backward"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["userNameLabel"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["loginNameLabel"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.staticTexts["descriptionLabel"].waitForExistence(timeout: 5))
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
