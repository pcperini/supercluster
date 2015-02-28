//
//  PostView.swift
//  supercluster
//
//  Created by Patrick Perini on 2/27/15.
//  Copyright (c) 2015 perini-hestin. All rights reserved.
//

import UIKit

@IBDesignable class PostView: UICollectionViewCell {
    enum SourceType {
        case Twitter
        case Instagram
        case Foursquare
    }
    
    // Reuse
    override var reuseIdentifier: String {
        return className(self.dynamicType)
    }
    
    // Border
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            self.layer.borderColor = self.borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
}
