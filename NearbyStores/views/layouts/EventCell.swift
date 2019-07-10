//
//  EventCell.swift
//  NearbyStores
//
//  Created by Amine on 6/12/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class EventCell: UICollectionViewCell {

    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var eventDates: UILabel!
    
    @IBOutlet weak var upcomingLabel: EdgeLabel!
    
    func setupSettings()  {
        
        
        //distance tag
        distance.leftTextInset = 10
        distance.rightTextInset = 10
        distance.bottomTextInset = 5
        distance.topTextInset = 5
        distance.backgroundColor = Colors.primaryColor
        
        
        featured.leftTextInset = 10
        featured.rightTextInset = 10
        featured.bottomTextInset = 5
        featured.topTextInset = 5
        featured.backgroundColor = Colors.featuredTagColor
        upcomingLabel.text = "Featured".localized
        
        
        upcomingLabel.leftTextInset = 10
        upcomingLabel.rightTextInset = 10
        upcomingLabel.bottomTextInset = 5
        upcomingLabel.topTextInset = 5
        upcomingLabel.backgroundColor = Colors.upComingColor
        upcomingLabel.text = "Upcoming".localized
        
        
        image.contentMode = .scaleAspectFill
        

    
    }
    
    
    
    func setup(object: Event)  {
        
        self.title.text = object.name
        
        let icon = UIImage.init(icon: .googleMaterialDesign(.dateRange), size: CGSize(width: 20, height: 20), textColor: UIColor.white)
        self.address.setLeftIcon(image: icon)
        
        
        //set image
        
        if object.listImages.count > 0 {
            
            
            if let first = object.listImages.first {
                
                let url = URL(string: first.url500_500)
                
                self.image.kf.indicatorType = .activity
                self.image.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                
            }else{
                if let img = UIImage(named: "default_store_image") {
                    self.image.image = img
                }
            }
        }else{
            
            if let img = UIImage(named: "default_store_image") {
                self.image.image = img
            }
        }
        
        
        
        let distance = object.distance.calculeDistance()
        self.distance.text = distance.getCurrent(type: Distance.Types.Kilometers)
        
        
        if object.featured == 1 {
            self.featured.isHidden = false
        }else {
            self.featured.isHidden = true
        }
        
        
        let begin_at = DateUtils.UTCToLocal(date: object.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatUTC)
        let end_at = DateUtils.UTCToLocal(date: object.dateEnd, fromFormat:  DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatUTC)
        
        self.eventDates.text = "\(begin_at) - \(end_at)"
        
        
        if DateUtils.isLessThan24(dateUTC: object.dateBegin){
            upcomingLabel.isHidden = false
        }else{
            upcomingLabel.isHidden = true
        }
        
    }
    
}
