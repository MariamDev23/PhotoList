//
//  ImageDownloadOperation.swift
//  PhotoList
//
//  Created by Mariam on 9/12/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloadHandler = (_ location: URL?, _ url: URL, _ error: Error?) -> Void

class ImageDownloadOperation: Operation {
    
    var downloadHandler: ImageDownloadHandler?
    var downloadingSession: URLSession!
    var imageUrl: URL!

    required init (url: URL, session: URLSession) {
        self.imageUrl = url
        self.downloadingSession = session
    }
    
    override var isAsynchronous: Bool {
        get {
            return  true
        }
    }
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }


    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        executing(true)
        downloadImage()
    }

    func downloadImage() {
        let downloadTask = downloadingSession.downloadTask(with: imageUrl) {[weak self] (location, response, error) in
            if let locationUrl = location, let imageUrl = self?.imageUrl {
                self?.downloadHandler?(locationUrl, imageUrl, error)
            }
            self?.finish(true)
            self?.executing(false)
        }
        downloadTask.resume()
    }

}
