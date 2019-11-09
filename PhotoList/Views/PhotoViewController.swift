//
//  PhotoViewController.swift
//  PhotoList
//
//  Created by Mariam on 9/12/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import UIKit

// Kept logic in VC for this one since it doesn't do much
class PhotoViewController : UIViewController, UITextViewDelegate {
    
    var photo: Photo!
    
    private var isTitleChanged = false
    
    @IBOutlet private weak var titleView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.text = photo.title
        let dataManager = DataManager.shared
        guard let url = photo.url else { return }
        if let image = dataManager.imageWithUrl(url) {
            imageView.image = image
        } else {
            dataManager.loadImageWithUrl(url) { [weak self] (image) in
                OperationQueue.main.addOperation() {
                    self?.imageView.image = image
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isTitleChanged {
            DataManager.shared.updatePhotoTitle(photoID: photo.photoID, title: titleView.text)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        isTitleChanged = true
    }
}
