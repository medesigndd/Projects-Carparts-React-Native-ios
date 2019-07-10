//
//  TextUtils.swift
//  NearbyStores
//
//  Created by Amine on 5/31/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika



extension String{
    
    func toHtml() -> AttributedText {
        
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 14)
        let all = Style.font(font!)
        let b = Style("b").font(.boldSystemFont(ofSize: 14))
        let u = Style("u").underlineStyle(.styleSingle)
        let i = Style("i").font(.italicSystemFont(ofSize: 14))
        
        let link = Style
            .foregroundColor(Colors.primaryColor, .normal)
            .foregroundColor(.brown, .highlighted)
        
        
        return self.style(tags: b,u,i)
            .styleLinks(link)
            .styleAll(all)
    }
    
    
    
}

extension String {
    
    
    
    var htmlToAttributedString: NSAttributedString? {
        
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
        
        
    }
    var htmlToString: String {
        
        
        return htmlToAttributedString?.string ?? ""
    }
}



extension String {
    
    
    
    
    
    
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

