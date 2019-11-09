//
//  PhotosDataOperation.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation

class PhotosDataOperation: DataOperation {
    
    static let URL = "https://jsonplaceholder.typicode.com/photos"
    
    override init(successHandler success: @escaping (Any) -> Void, failureHandler failure: @escaping (Error?) -> Void) {
        super.init(successHandler: success, failureHandler: failure)
        urlString = PhotosDataOperation.URL
    }
    
    override func handleData(_ data: Any) {
        if let photoDataList = data as? [[String: Any]] {
            var photos = [Photo]()
            for photoData in photoDataList {
                photos.append(Photo(withData: photoData))
            }
            super.handleData(photos)
        } else {
            super.handleError(nil)
        }
    }
}
