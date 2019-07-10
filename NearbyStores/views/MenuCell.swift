//
//  MenuCell.swift
//  NearbyStores
//
//  Created by Amine on 5/29/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class MenuCell: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = Colors.darkColor
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            imageView.tintColor = isHighlighted ? UIColor.white : Colors.darkIconColor
        }
    }
    
    override var isSelected: Bool {
        didSet {

            imageView.tintColor = isSelected ? UIColor.white : Colors.darkIconColor
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:[v0(35)]", views: imageView)
        addConstraintsWithFormat(format: "V:[v0(35)]", views: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}
