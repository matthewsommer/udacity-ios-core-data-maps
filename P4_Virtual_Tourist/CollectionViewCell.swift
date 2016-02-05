//
//  CollectionViewCell.swift
//  P4_Virtual_Tourist
//
//  Created by Matt Sommer on 2/2/16.
//  Copyright © 2016 Matt Sommer. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewSelectedMask: UIView!
    
    var color: UIColor {
        set {
            self.viewSelectedMask.backgroundColor = newValue
        }
        
        get {
            return self.viewSelectedMask.backgroundColor ?? UIColor.whiteColor()
        }
    }
}