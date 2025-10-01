import XCTest
@testable import FoodForEyesApp

final class ImagesListViewControllerTests: XCTestCase {
    
    var viewController: ImagesListViewControllerSpy!
    var presenter: ImagesListPresenterSpy!
    
    override func setUp() {
        super.setUp()
        
        // Given - базовая настройка для всех тестов
        viewController = ImagesListViewControllerSpy()
        presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
    }
    
    override func tearDown() {
        viewController = nil
        presenter = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsPresenter() {
        
        // When
        viewController.simulateViewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "ViewController должен вызывать presenter.viewDidLoad()")
    }
    
    
    func testPresenterCallsReloadTableView() {
        
        // When
        presenter.simulatePhotosUpdated()
        
        // Then
        XCTAssertTrue(viewController.reloadTableViewCalled, "Presenter должен вызывать обновление таблицы")
    }
    
    func testViewControllerLoadsSuccessfully() {
    
        // When
        viewController.loadViewIfNeeded()
        
        // Then
        XCTAssertNotNil(viewController.view, "View должна загружаться")
        XCTAssertTrue(viewController.isViewLoaded, "View должна быть загружена")
    }
}

// MARK: - ImagesListViewControllerSpy
final class ImagesListViewControllerSpy: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol!
    
    // Флаги вызовов методов
    var reloadTableViewCalled = false
    var reloadRowCalled = false
    var reloadRowIndexPath: IndexPath?
    var insertRowsCalled = false
    var insertRowsIndexPaths: [IndexPath]?
    var showSingleImageCalled = false
    var showSingleImageIndexPath: IndexPath?
    var showLikeErrorAlertCalled = false
    var showLikeErrorAlertError: Error?
    
    func simulateViewDidLoad() {
        presenter.viewDidLoad()
    }
    
    // MARK: - ImagesListViewControllerProtocol
    
    func reloadTableView() {
        reloadTableViewCalled = true
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
        reloadRowIndexPath = indexPath
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
        insertRowsIndexPaths = indexPaths
    }
    
    func showSingleImage(for indexPath: IndexPath) {
        showSingleImageCalled = true
        showSingleImageIndexPath = indexPath
    }
    
    func showLikeErrorAlert(error: Error) {
        showLikeErrorAlertCalled = true
        showLikeErrorAlertError = error
    }
    
    func getIndexPath(for cell: ImagesListCell) -> IndexPath? {
        return IndexPath(row: 0, section: 0)
    }
}

// MARK: - ImagesListPresenterSpy
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var photosCountToReturn = 0
    
    var photosCount: Int {
        return photosCountToReturn
    }
    
    func simulatePhotosUpdated() {
        view?.reloadTableView()
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        return Photo(
            id: "test",
            size: CGSize(width: 100, height: 200),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "test",
            largeImageURL: "test",
            isLiked: false
        )
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
    }
    
    func heightForRowAt(indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        return 200
    }
}
