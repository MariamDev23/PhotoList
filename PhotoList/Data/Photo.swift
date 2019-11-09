//
//  Photo.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation

class Photo {
    
    struct DataKeys {
        static let photoID = "id"
        static let title = "title"
        static let thumbnailUrl = "thumbnailUrl"
        static let url = "url"
    }
    
    var photoID: Int!
    var title: String?
    var thumbnailUrl: String?
    var url: String?
    
    init() {}
    
    init(withData data: [String: Any]) {
        updateWithData(data)
    }
    
    func updateWithData(_ data: [String: Any]) {
        photoID = data[Photo.DataKeys.photoID] as! Int
        title = data[Photo.DataKeys.title] as? String
        thumbnailUrl = data[Photo.DataKeys.thumbnailUrl] as? String
        url = data[Photo.DataKeys.url] as? String
    }
}
