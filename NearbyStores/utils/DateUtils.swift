//
//  DateUtils.swift
//  NearbyStores
//
//  Created by Amine on 6/13/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Foundation

class DateFomats {
    static let defaultFormatTimeUTC = "yyyy-MM-dd HH:mm:ss"
    static let defaultFormatUTC = "yyyy-MM-dd HH:mm"
    static let defaultFormatDate = "MMM dd,yyyy"
    static let defaultFormatDateTime = "MMM dd,yyyy HH:mm"
    static let defaultFormatTime = "HH:mm"
    
}

class DateUtils: NSObject {
    
    static let defaultFormatUTC = "yyyy-MM-dd HH:mm:ss"
    static let defaultFormatDate = "MMM dd,yyyy"
    static let defaultFormatDateTime = "MMM dd,yyyy HH:mm"
    static let defaultFormatTime = "HH:mm"
    
    static func isLessThan24(components: DateComponents) -> Bool {
        
        guard components.year! == 0 else { return false }
        guard components.month! == 0 else { return false }
        guard components.day! == 0 else { return false }
        guard components.hour! <= 24  else { return false }
        
        return true
    }
    
    static func isLessThan60seconds(components: DateComponents) -> Bool {
        
        guard components.year! >= 0 else { return false }
        guard components.month! >= 0 else { return false }
        guard components.day! >= 0 else { return false }
        guard components.hour! >= 0  else { return false }
        guard components.minute! >= 0  else { return false }
        
        return true
    }
    
    

    
    
    static func isLessThan24(dateUTC: String) -> Bool{
        
        let dateRangeStart = Date()
        
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateRangeStart, to: dateEnd)
            
            
            if isLessThan24(components: components) {
                return true
            }
            
        }
        
        return false
    }
    
    static func getPreparedDateDT(dateUTC: String) -> String{
        
        let dateRangeStart = Date()
        
        if let dateEnd = self.convertToDate(dateUTC: dateUTC) {
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateRangeStart, to: dateEnd)
            

            if isLessThan60seconds(components: components){
                return "Just Now".localized
            }else if isLessThan24(components: components) {
                return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatTime)
            }
            
            
        }
        
        
        return self.UTCToLocal(date: dateUTC, fromFormat: defaultFormatUTC, toFormat: defaultFormatDate)
        
    }
    
    static func convertToDate(dateUTC: String) -> Date?{
        
        //convert date to current timezone
        
        let dateByCTZ = self.UTCToLocal(date: dateUTC,
                                        fromFormat: self.defaultFormatUTC,
                                        toFormat: self.defaultFormatUTC)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.defaultFormatUTC
        dateFormatter.calendar = NSCalendar.current
        
        return dateFormatter.date(from: dateByCTZ)
    }
    
    static func getCurrent(format: String) -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    static func getCurrentUTC(format: String) -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    static func localToUTC(date:String, fromFormat: String, toFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.date
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: dt!)
    }
    
    static func UTCToLocal(date:String, fromFormat: String, toFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: dt!)
    }
    
}
