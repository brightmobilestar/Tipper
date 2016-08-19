//
//  KNNSDateExtension.swift
//  Tipper
//
//  Created by Thach Bui-Khac on 12/1/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//

import Foundation

extension NSDate {
    func toString(let format:String) -> String? {
        var formatter:NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    class func getCurrentDate() -> NSDate? {
        return NSDate()
    }
    
    class func getBetweenDays(startDate: NSDate, endDate: NSDate) -> Int {
        var calendar: NSCalendar = NSCalendar.currentCalendar()
        return calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: startDate, toDate: endDate, options: nil).day
    }
    
    class func getBetweenSeconds(startDate: NSDate, endDate: NSDate) -> Int {
    
        var calendar: NSCalendar = NSCalendar.currentCalendar()
        return calendar.components(NSCalendarUnit.SecondCalendarUnit, fromDate: startDate, toDate: endDate, options: nil).second
    }
}
