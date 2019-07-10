//
//  MyUtils.swift
//  NearbyStores
//
//  Created by Amine on 5/21/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SystemConfiguration


class Connectivity {
    
    class func isConnected() -> Bool{
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
 
    }
}

class Utils {
    
    static func isRTL() -> Bool  {
        
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return true
        }
        
        return false
    }
    
    
    static func convertToDictionary(text: String) -> JSON? {
        
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            
            do {
                return try JSON(data: dataFromString)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
    
    
    static func setFontRegular(labels: UILabel...){
        
        for view in labels {
            let font = UIFont(name: AppConfig.Design.Fonts.regular, size: view.font.pointSize)
            view.font = font
        }
        
    }
    
    static func setFontBold(labels: UILabel...){
        
        for view in labels {
            let font = UIFont(name: AppConfig.Design.Fonts.bold, size: view.font.pointSize)
            view.font = font
        }
        
    }
    
    
    
    static func printDebug(_ message: String){
        
        if AppConfig.DEBUG {
            print(message)
        }
        
    }
    
    static func printDebug(_ tag: String,_ message: String){
        
        if AppConfig.DEBUG {
            print("Debug ***\(tag) ****===> ",message)
        }
        
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}


extension UILabel{
    
    func useFontRegular(){
        
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: self.font.pointSize)
        self.font = font
        
    }
    
    
    func useFontBold(){
        
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: self.font.pointSize)
        self.font = font
        
    }
}


extension UIButton{
    
    func useFontRegular(){
        
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: (self.titleLabel?.font.pointSize)!)
        self.titleLabel?.font = font
        
    }
    
    
    func useFontBold(){
        
        let font = UIFont(name: AppConfig.Design.Fonts.bold, size: (self.titleLabel?.font.pointSize)!)
        self.titleLabel?.font = font
        
        
    }
    
    private func actionHandleBlock(action:(() -> Void)? = nil) {
        struct __ {
            static var action :(() -> Void)?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?()
        }
    }
    
    @objc private func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func actionHandle(controlEvents control :UIControlEvents, ForAction action:@escaping () -> Void) {
        self.actionHandleBlock(action: action)
        self.addTarget(self, action: "triggerActionHandleBlock", for: control)
    }
}


extension UIView{
    
}



extension UILabel{
    
    func setLeftIcon(image: UIImage) {
        
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffsetY:CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string
        completeText.append(attachmentString)
        //Add your text to mutable string
        let  textAfterIcon = NSMutableAttributedString(string: self.text!)
        completeText.append(textAfterIcon)
        
        if Utils.isRTL(){
            self.textAlignment = .right;
        }else{
            self.textAlignment = .left;
        }
        
        self.attributedText = completeText;
    }
    
    
    func setRightIcon(image: UIImage) {
        
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffsetY:CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        //Add image to mutable string
        
        //Add your text to mutable string
        let  textAfterIcon = NSMutableAttributedString(string: self.text!)
        completeText.append(textAfterIcon)
        completeText.append(attachmentString)
       
        if Utils.isRTL(){
            self.textAlignment = .right;
        }else{
            self.textAlignment = .left;
        }
        
        self.attributedText = completeText;
    }
    
    
    
    
}


extension UICollectionView {
    
    
//    func getLastIndexPath() -> IndexPath{
//
//        guard numberOfSections > 0 else {
//            return
//        }
//
//        let lastItemIndex = numberOfItems(inSection: 0) > 0 ? numberOfItems(inSection: lastSection) - 1 : 0
//
//
//        let lastItemIndexPath = IndexPath(item: lastItemIndex,
//                                          section: 0)
//
//        return lastItemIndexPath
//    }
//
//
//    func getLastIndex() -> Int{
//
//        guard numberOfSections > 0 else {
//            return
//        }
//
//        let lastItemIndex = numberOfItems(inSection: 0) > 0 ? numberOfItems(inSection: lastSection) - 1 : 0
//
//
//        return lastItemIndex
//    }
    
    func scrollToLast() {
        guard numberOfSections > 0 else {
            return
        }
     
        let lastItemIndex = numberOfItems(inSection: 0) > 0 ? numberOfItems(inSection: 0) - 1 : 0
        
        guard numberOfItems(inSection: 0) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: lastItemIndex,
                                          section: 0)
        
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
    }
    
}

class Localization {
    static var list_to_translate:[String:String] = [:]
}


extension String {
    
    var localized: String {
        
        if AppConfig.DEBUG{
           Localization.list_to_translate[self] = self
        }
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
    
    func format(arguments: CVarArg...) -> String {
        let text: String = self
        return String(format: text, arguments: arguments)
    }
    
}
