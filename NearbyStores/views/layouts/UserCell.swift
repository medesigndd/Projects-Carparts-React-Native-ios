//
//  UserCell.swift
//  NearbyStores
//
//  Created by Amine on 6/28/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons

class UserCell: UICollectionViewCell {
    
    var optionLauncher: OptionsLauncher? = nil
    var object: User? = nil
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var option: UIButton!
    
    @IBOutlet weak var gradientView: GradientBGView!
    
   
    
    @IBAction func onOptionMore(_ sender: Any) {
        
        if let launcher = self.optionLauncher {
            
            launcher.clear()
            
            if let user = self.object  {
                
                if user.blocked {
                    
                    launcher.addBottomMenuItem(option: Option(
                        id: OptionsId.UNBLOCK,
                        name: "Unblock".localized,
                        image: launcher.createIcon(.ionicons(.androidClose)),
                        object: user.id
                    ))
                    
                }else{
                    
                    launcher.addBottomMenuItem(option: Option(
                        id: OptionsId.BLOCK,
                        name: "Block".localized,
                        image: launcher.createIcon(.ionicons(.androidClose)),
                        object: user.id
                    ))
                    
                    launcher.addBottomMenuItem(option: Option(
                        id: OptionsId.SENDMESSAGE,
                        name: "Send Message".localized,
                        image: launcher.createIcon(.ionicons(.iosChatbubble)),
                        object: user.id
                    ))
                }
                
                
            }
            
            launcher.load()
            launcher.showOptions()
        }
        
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Colors.highlightedGray : UIColor.white
        }
    }
    
    
    func setupSettings()  {
       
        
        image.contentMode = .scaleAspectFill
        
        image.layer.borderWidth = 2
        image.layer.masksToBounds = false
        image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        
        
        name.textColor = Colors.primaryColor
        
    
        if Utils.isRTL(){
            
            desc.textAlignment = .right
            
            let startColor = gradientView.startColor
            let endColor = gradientView.endColor
            
            gradientView.startColor = endColor
            gradientView.endColor = startColor
            
            gradientView.alpha = CGFloat(0.7)
           
        }
        
        gradientView.isHidden = true
        
    }
    
    func setOptionLauncher(optionsLauncher: OptionsLauncher) {
        self.optionLauncher = optionsLauncher
    }
    
    func getDistance(distance: Double) -> String {
        
        if distance < 1000 {
            return " "+("less than 1KM".localized)
        }else if distance >= 1000 && distance < 2000 {
            return " ("+("+1 KM".localized)+")"
        }else if distance >= 2000 && distance < 5000{
            return " ("+("+2 KM".localized)+")"
        }else if distance >= 5000 {
            return " ("+("+5 KM".localized)+")"
        }
        
        return ""
    }
    
    func setup(object: User)  {
        
        self.object = object
     
        self.option.setIcon(icon: .ionicons(.androidMoreVertical), iconSize: 24, color: Colors.primaryColor, forState: .normal)
        
        
        self.name.text = object.name
        
//        if Utils.isRTL(){
//
//            self.desc.text = self.getDistance(distance: object.distance)+" @"+object.username
//
//        }else{
//
//            self.desc.text = "@"+object.username+self.getDistance(distance: object.distance)
//
//        }
        
        self.desc.text = self.getDistance(distance: object.distance)
        
        
        
        if object.blocked {
            self.name.textColor = Colors.gray
        }else{
            self.name.textColor = Colors.primaryColor
        }
        
       
        
        //set image
        if let image = object.images {
            
            let url = URL(string: image.url100_100)
            
            self.image.kf.indicatorType = .activity
            self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
            
        }else{
            if let img = UIImage(named: "profile_placeholder") {
                self.image.image = img
            }
        }
        
        
    }

}









