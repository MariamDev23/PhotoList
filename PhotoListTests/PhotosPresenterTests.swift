//
//  PhotosPresenterTests.swift
//  PhotoListTests
//
//  Created by Mariam on 9/12/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import XCTest

class MockDataManagerInterface: DataManagerInterface {
    weak var delegate: DataChangedDelegate?
    var photos = [Photo]()
    
    var isLoadPhotosCalled = false
    var isGetImageCalled = false
    var isLoadImageCalled = false
    var cachedImage: UIImage?
    
    init() {
        let photo1 = Photo()
        photo1.photoID = 1
        photo1.title = "Photo1"
        let photo2 = Photo()
        photo2.photoID = 2
        photo2.title = "Photo2"
        let photo3 = Photo()
        photo3.photoID = 3
        photo3.title = "Photo3"
        photos = [photo3, photo1, photo2]
    }
    
    func allPhotos() -> [Photo] {
        return photos
    }
    
    func loadPhotos(_ completionHandler: @escaping ([Photo], Error?) -> Void) {
        isLoadPhotosCalled = true
        completionHandler(photos, nil)
    }
    
    func imageWithUrl(_ urlString: String) -> UIImage? {
        isGetImageCalled = true
        return cachedImage
    }
    
    func loadImageWithUrl(_ urlString: String, completionHandler: @escaping ((UIImage?) -> Void)) {
        completionHandler(nil)
        isLoadImageCalled = true
    }
    
    func updatePhotoTitle(photoID: Int, title: String) {}
}

class MockView: PhotosViewInterface {
    
    var isShowLoadingCalled = false
    var isHideLoadingCalled = false
    var isShowErrorCalled = false
    
    var photos = [Photo]()
    
    func showLoading() {
        isShowLoadingCalled = true
    }
    
    func hideLoading() {
        isHideLoadingCalled = true
    }
    
    func showError(_ errorText: String) {
        isShowErrorCalled = true
    }
    
    func setPhotos(_ photos: [Photo]) {
        self.photos = photos
    }
    func update() {}
    func visiblePhotosIDs() -> [Int] {
        return [Int]()
    }
}

extension Photo: Equatable { }

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.title == rhs.title
}

class PhotosPresenterTests: XCTestCase {
    
    private enum PhotosPresenterTestsError : Error {
        case testError
    }
    
    private var photosPresenter: PhotosPresenter!
    private var mockDataManager: MockDataManagerInterface!
    private var mockView: MockView!
    
    override func setUp() {
        super.setUp()
        mockDataManager = MockDataManagerInterface()
        photosPresenter = PhotosPresenter(dataManager: mockDataManager)
        mockView = MockView()
        photosPresenter.photosView = mockView
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewIsReady() {
        photosPresenter.viewIsReady()
        XCTAssert(mockView.isShowLoadingCalled, "View should initiallly show loading")
        XCTAssert(mockDataManager.isLoadPhotosCalled, "Photos loading should be requested")
    }
    
    func testLoadedPhotosHandling() {
        photosPresenter.handleLoadedPhotos(mockDataManager.photos, error: nil)
        XCTAssert(mockView.isHideLoadingCalled, "View should hide loading when photos loading result received")
        XCTAssert(mockView.photos.count == 3, "Incorrect number of items passed to view")
        XCTAssert(mockView.photos[0].photoID == 1, "Photos not sorted corrected")
        XCTAssert(mockView.photos[1].photoID == 2, "Photos not sorted corrected")
        XCTAssert(mockView.photos[2].photoID == 3, "Photos not sorted corrected")
        mockView.photos.removeAll()
        photosPresenter.handleLoadedPhotos(mockDataManager.photos, error: PhotosPresenterTestsError.testError)
        XCTAssert(mockView.isShowErrorCalled, "Error should be shown")
    }
    
    func testThumbnailRetrieval() {
        let photo1 = Photo()
        photo1.photoID = 1
        let testImage = UIImage()
        mockDataManager.cachedImage = testImage
        var image = photosPresenter.thumbnailForPhoto(photo1)
        XCTAssert(image == nil, "Should not return any image since photo doesn't have thumbnail URL")
        photo1.thumbnailUrl = "someURL"
        image = photosPresenter.thumbnailForPhoto(photo1)
        XCTAssert(mockDataManager.isGetImageCalled, "Should try to get loaded thumbnail")
        XCTAssert(testImage == image, "Should return loaded thumbnail")
        mockDataManager.cachedImage = nil
        image = photosPresenter.thumbnailForPhoto(photo1)
        XCTAssert(image == nil, "Should not return any image")
        XCTAssert(mockDataManager.isLoadImageCalled, "Should initiate image loading")
    }
    
    func testFiltering() {
        let photo1 = Photo()
        photo1.photoID = 1
        photo1.title = "Photo1"
        let photo2 = Photo()
        photo2.photoID = 2
        photo2.title = "Photo22"
        let photo3 = Photo()
        photo3.photoID = 3
        photo3.title = "Photo32 Photos"
        let photos = [photo3, photo1, photo2]
        var filteredPhotos = photosPresenter.filteredPhotos(from: photos, withText: "Photo")
        XCTAssert(filteredPhotos.contains(photo1) && filteredPhotos.contains(photo2) && filteredPhotos.contains(photo3), "Should contain all matching photos")
        filteredPhotos = photosPresenter.filteredPhotos(from: photos, withText: "photo1")
        XCTAssert(filteredPhotos.contains(photo1), "Filtering should be case insensitive")
        filteredPhotos = photosPresenter.filteredPhotos(from: photos, withText: "2")
        XCTAssert(filteredPhotos.contains(photo2) && filteredPhotos.contains(photo3), "Should contain matching photos")
        XCTAssert(filteredPhotos[0] == photo3, "Order of photos should not be changed")
        filteredPhotos = photosPresenter.filteredPhotos(from: photos, withText: " P")
        XCTAssert(filteredPhotos.contains(photo3), "Should contain matching photos")
        filteredPhotos = photosPresenter.filteredPhotos(from: photos, withText: "some text")
        XCTAssert(filteredPhotos.isEmpty, "filteredPhotos should be empty")
    }
}
