//
//  FoodForEyesAppTests.swift
//  FoodForEyesAppTests
//
//  Created by Мария уже Ревина on 10.07.2025.
//

import XCTest
@testable import FoodForEyesApp

final class FoodForEyesAppTests: XCTestCase {
    func testFetchPhotos() {
        let  service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for not")
        
        NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main) {  _ in
            expectation.fulfill()
        }
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
