//
//  PhotosTableViewController.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import UIKit

class PhotosTableViewController: UITableViewController, PhotosViewInterface, UISearchResultsUpdating {
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var photos = [Photo]()
    private let photosPresenter = PhotosPresenter(dataManager: DataManager.shared)
    
    private var selectedPhoto: Photo?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupActivityView()
        photosPresenter.photosView = self
        photosPresenter.viewIsReady()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.id, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        cell.setPhotoTitle(photo.title, partToHighlight: searchController.searchBar.text)
        cell.thumbnailImageView.image = photosPresenter.thumbnailForPhoto(photo)
        cell.setNeedsLayout()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhoto = photos[indexPath.row]
        performSegue(withIdentifier: "PhotoSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoViewController = segue.destination as? PhotoViewController, let photo = selectedPhoto {
            photoViewController.photo = photo
            selectedPhoto = nil
        }
    }
    
    // PhotosViewInterface
    
    func showLoading() {
        activityIndicator.isHidden = false
    }
    
    func hideLoading() {
        activityIndicator.isHidden = true
    }
    
    func showError(_ errorText: String) {
        let alertController = UIAlertController(title: "Failure", message: errorText, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    func setPhotos(_ photos: [Photo]) {
        self.photos = photos
        tableView.reloadData()
    }

    func update() {
        tableView.reloadData()
    }
    
    func visiblePhotosIDs() -> [Int] {
        var visiblePhotosIDs = [Int]()
        if let indexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                visiblePhotosIDs.append(photos[indexPath.row].photoID)
            }
        }
        return visiblePhotosIDs
    }
    
    // UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        photosPresenter.filterPhotosBySearchText(searchController.searchBar.text)
    }
    
    // Helpers
    
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 95
        tableView.tableFooterView = UIView()
    }
    
    private func setupActivityView() {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.bringSubview(toFront: view)
    }
    
    private func setupSearchBar() {
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search Photos"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
    }
}

