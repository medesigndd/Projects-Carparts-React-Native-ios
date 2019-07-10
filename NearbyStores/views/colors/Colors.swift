//
//  Colors.swift
//  NearbyStores
//
//  Created by Amine on 5/22/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

struct Colors {

    static let white: UIColor =  Utils.hexStringToUIColor(hex: "#FFFFFF")
    static let white_50: UIColor =  Utils.hexStringToUIColor(hex: "#80FFFFFF")
    static let gray: UIColor =  Utils.hexStringToUIColor(hex: "#90A4AE")
    static let black: UIColor =  Utils.hexStringToUIColor(hex: "#000000")
    static let highlightedGray: UIColor =  Utils.hexStringToUIColor(hex: "#eeeeee")
    
    
    
    static let black_30: UIColor =  Colors.black.withAlphaComponent(CGFloat(0.3))
    static let black_50: UIColor =  Colors.black.withAlphaComponent(CGFloat(0.5))
    static let black_70: UIColor =  Colors.black.withAlphaComponent(CGFloat(0.7))
    
    
    //load from config file
    static let primaryColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.primaryColor)
    
    static let primaryColorTransparency_50: UIColor = Colors.primaryColor.withAlphaComponent(CGFloat(0.5))
    
    static let accentColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.accentColor)
    static let darkColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.darkColor)
    static let darkIconColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.darkIconColor)
    static let featuredTagColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.featuredTagColor)
    static let promoTagColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.promoTagColor)
    static let upComingColor: UIColor = Utils.hexStringToUIColor(hex: AppConfig.Design.Colors.upComingColor)
    
    
    
    static let bg_gray: UIColor =  Utils.hexStringToUIColor(hex: "#EEEEEE")
    
    
}
