//
//  CustomTextField.swift
//  NearbyStores
//
//  Created by Amine on 5/22/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    
    
    var placeHolderText = ""

    override func awakeFromNib() {
    
        
        let editFont = AppConfig.Design.Fonts.regular
       
        self.font = UIFont(name: editFont, size: 18)

        layer.borderWidth = 0.5/UIScreen.main.nativeScale
        layer.borderColor = Colors.gray.cgColor
        
        self.tintColor = Colors.gray

        self.layer.cornerRadius = 1.0
        self.clipsToBounds = true
        
        
       
        
        
    }
    
    
    override func layoutSubviews() {
        
        var cgr = self.frame
        cgr.size.height = CGFloat(Constances.CustomSize.CUSTOM_HEIGHT_TEXTFIELDS); // <-- Specify the height you want here.
        self.frame = cgr
        
    }
}
