//
//  SVProgressExtended.swift
//  NearbyStores
//
//  Created by Amine on 5/27/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SVProgressHUD

class MyProgress {

}


extension MyProgress{
    
    static func show() {
        
        SVProgressHUD.setForegroundColor(Colors.primaryColor)
        SVProgressHUD.setBorderColor(Colors.primaryColor)
        SVProgressHUD.setBackgroundColor(Colors.white)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setBackgroundLayerColor( UIColor (white: 1, alpha: CGFloat(0.5))  )
        SVProgressHUD.show()
        
    }
    
    static func show(parent: UIView) {
        
        SVProgressHUD.setForegroundColor(Colors.primaryColor)
        SVProgressHUD.setBorderColor(Colors.primaryColor)
        SVProgressHUD.setBackgroundColor(Colors.white)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setBackgroundLayerColor( UIColor (white: 1, alpha: CGFloat(0.2))  )
        SVProgressHUD.setContainerView(parent)
        SVProgressHUD.show()
        
    }
    
    static func dismiss() {
        
        SVProgressHUD.dismiss()
        
    }
    
  
    
    
    static func showProgressWithSuccess(withStatus: String) {
        
        SVProgressHUD.setForegroundColor(Colors.primaryColor)
        SVProgressHUD.setBorderColor(Colors.primaryColor)
        SVProgressHUD.setBackgroundColor(Colors.white)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setBackgroundLayerColor( UIColor (white: 1, alpha: CGFloat(0.5))  )
        SVProgressHUD.show()
        
        SVProgressHUD.showSuccess(withStatus: withStatus)
        
        
    }
    
    
    
}
