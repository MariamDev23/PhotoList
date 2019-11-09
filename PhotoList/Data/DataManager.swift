//
//  DataManager.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation
import UIKit

protocol DataChangedDelegate: class {
    func photosUpdated()
}

protocol DataManagerInterface{
    var delegate: DataChangedDelegate? {get set}
    func allPhotos() -> [Photo]
    func loadPhotos(_ completionHandler: @escaping ([Photo], Error?) -> Void)
    func imageWithUrl(_ urlString: String) -> UIImage?
    func loadImageWithUrl(_ urlString: String, completionHandler: @escaping ((UIImage?) -> Void))
    func updatePhotoTitle(photoID: Int, title: String)
}

class DataManager: DataManagerInterface {
    
    static let shared = DataManager()
    
    weak var delegate: DataChangedDelegate?
    
    // NOTE: It also would be good to store data of the downloaded images in files and have a cache which will contain locations of these files. If the mapping from image url to it's file location is stored like in UserDefaults there won't be a necessity to download images again after killing the app and launching it again. Cache would be cleened up periodically (like every couple of days). Just haven't gone that far.
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        return cache
    }()
    
    private lazy var downloadingSession: URLSession = {
        //NOTE: Haven't enabled background download since image sizes seemed fairly small
        let config = URLSessionConfiguration.default//background(withIdentifier: "krispTest.download")
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()
    
    lazy private var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.krispTest.imageDownloadQueue"
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 100
        return queue
    }()
    
    private var photosOperation: PhotosDataOperation?
    
    private var photos = [Int: Photo]()
    
    init() {}
    
    func allPhotos() -> [Photo] {
        return photos.map({$0.value})
    }
    
    func loadPhotos(_ completionHandler: @escaping ([Photo], Error?) -> Void) {
        photosOperation = PhotosDataOperation(successHandler: { [weak self] photosData in
            if let photosList = photosData as? [Photo] {
                self?.photos.removeAll()
                for photo in photosList {
                    self?.photos[photo.photoID] = photo
                }
                completionHandler(photosList, nil)
            }
            self?.photosOperation = nil
        }, failureHandler: { [weak self] error in
            completionHandler([], error)
            self?.photosOperation = nil
        })
        photosOperation!.loadData()
    }
    
    func imageWithUrl(_ urlString: String) -> UIImage? {
        return imageCache.object(forKey: urlString as NSString)
    }
    
    func loadImageWithUrl(_ urlString: String, completionHandler: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: urlString) else { return }
        if let operations = (imageDownloadQueue.operations as? [ImageDownloadOperation])?.filter({$0.imageUrl.absoluteString == url.absoluteString && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
            operation.queuePriority = .veryHigh
        } else {
            let operation = ImageDownloadOperation(url: url, session: downloadingSession)
            operation.downloadHandler = { [weak self] (location, url, error) in
                if let imageLocation = location, let data = try? Data(contentsOf: imageLocation), let image = UIImage(data: data) {
                    self?.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completionHandler(image)
                }
            }
            imageDownloadQueue.addOperation(operation)
        }
    }
    
    func updatePhotoTitle(photoID: Int, title: String) {
        photos[photoID]?.title = title
        delegate?.photosUpdated()
    }
}
