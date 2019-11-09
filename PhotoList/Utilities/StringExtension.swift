//
//  StringExtension.swift
//  PhotoList
//
//  Created by Mariam on 9/12/19.
//  Copyright © 2019 PhotoListMariam. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func stringWithHighlightedSubstring(_ subString: String, fontSize: CGFloat) -> NSAttributedString {
        let ranges = self.ranges(of: subString)
        let attributedText = NSMutableAttributedString(string: self)
        let font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
        attributedText.setAttributes([NSAttributedStringKey.font : font], range: NSMakeRange(0, self.count))
        for range in ranges {
            attributedText.setAttributes([NSAttributedStringKey.foregroundColor : UIColor.orange,
                                          NSAttributedStringKey.font : font], range: NSRange(range, in: self))
        }
        return attributedText
    }
    
    func ranges(of string: String, options: String.CompareOptions = [.caseInsensitive]) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
