//
//  CustomButton.swift
//  NearbyStores
//
//  Created by Amine on 5/22/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    /*
 
     guard let customFont = UIFont(name: "OpenSans-Italic", size: UIFont.labelFontSize) else {
     fatalError("""
     Failed to load the "CustomFont-Light" font.
     Make sure the font file is included in the project and the font name is spelled correctly.
     """
     )
     }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        

        self.layer.cornerRadius = 2.0
        self.clipsToBounds = true

        self.setTitleColor(Colors.white, for: .normal)
        self.setTitleColor(Colors.primaryColorTransparency_50, for: .disabled)
       self.titleLabel?.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
       // self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
      
       self.backgroundColor = Colors.primaryColor
        
        
    
       
    }
    
    
    
   
}
