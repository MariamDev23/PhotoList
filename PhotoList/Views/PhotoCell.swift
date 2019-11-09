//
//  PhotoCell.swift
//  PhotoList
//
//  Created by Mariam on 9/11/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    static let id = "PhotoCell"
    
    var textToHighlight: String?
    
    @IBOutlet private weak var titleView: UITextView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    func setPhotoTitle(_ title: String?, partToHighlight: String?) {
        titleView.textColor = UIColor.black
        if let highlight = partToHighlight, !highlight.isEmpty {
            titleView.text = nil
            titleView.attributedText = title?.stringWithHighlightedSubstring(highlight, fontSize: titleView.font!.pointSize)
        } else {
            titleView.attributedText = nil
            titleView.text = title
        }
    }
}
