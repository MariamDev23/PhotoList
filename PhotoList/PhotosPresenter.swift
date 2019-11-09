//
//  PhotosPresenter.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation
import UIKit

protocol PhotosViewInterface: class {
    func showLoading()
    func hideLoading()
    func showError(_ errorText: String)
    func setPhotos(_ photos: [Photo])
    func update()
    func visiblePhotosIDs() -> [Int]
}

class PhotosPresenter: DataChangedDelegate {
    
    var dataManager: DataManagerInterface
    weak var photosView: PhotosViewInterface?
    
    private var allPhotos: [Photo]?
    private let filteringQueue = OperationQueue()
    
    init(dataManager: DataManagerInterface) {
        self.dataManager = dataManager
        self.dataManager.delegate = self
    }
    
    func viewIsReady() {
        photosView?.showLoading()
        dataManager.loadPhotos { [weak self] (photos, error) in
            self?.handleLoadedPhotos(photos, error: error)
        }
    }
    
    func thumbnailForPhoto(_ photo: Photo) -> UIImage? {
        guard let url = photo.thumbnailUrl else { return nil }
        if let thumbnail = dataManager.imageWithUrl(url) {
            return thumbnail
        } else {
            dataManager.loadImageWithUrl(url) { [weak self] (image) in
                OperationQueue.main.addOperation() {
                    if let photosView = self?.photosView, photosView.visiblePhotosIDs().contains(photo.photoID) {
                        photosView.update()
                    }
                }
            }
            return nil
        }
    }
    
    func filterPhotosBySearchText(_ searchText: String?) {
        filteringQueue.cancelAllOperations()
        if let text = searchText, !text.isEmpty {
            if allPhotos == nil {
                allPhotos = sortPhotos(from: dataManager.allPhotos())
            }
            filteringQueue.addOperation(BlockOperation() { [weak self] in
                if let photos = self?.allPhotos, let filteredPhotos = self?.filteredPhotos(from: photos, withText: text) {
                    OperationQueue.main.addOperation() {
                        self?.photosView?.setPhotos(filteredPhotos)
                    }
                }
            })
        } else if let photos = allPhotos {
            photosView?.setPhotos(photos)
            allPhotos = nil
        }
    }
    
    // Helper methods
    
    func handleLoadedPhotos(_ photos: [Photo], error: Error?) {
        let sortedPhotos = sortPhotos(from: photos)
        photosView?.hideLoading()
        if let errorText = error?.localizedDescription {
            photosView?.showError(errorText)
        }
        photosView?.setPhotos(sortedPhotos)
    }
    
    func filteredPhotos(from photos: [Photo], withText text: String) -> [Photo] {
        var filteredPhotos = [Photo]()
        for photo in photos {
            let title = photo.title
            if title?.range(of: text, options: [.caseInsensitive]) != nil {
                filteredPhotos.append(photo)
            }
        }
        return filteredPhotos
    }
    
    private func sortPhotos(from photos: [Photo]) -> [Photo] {
        return photos.sorted(by: { $0.photoID < $1.photoID })
    }
    
    // DataChangedDelegate
    
    func photosUpdated() {
        photosView?.update()
    }
}
