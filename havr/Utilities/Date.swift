//
//  Date.swift
//  havr
//
//  Created by Personal on 5/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit

extension Date {
    static func create(from text: String?) -> Date? {
        
        guard let text = text, !(text.characters.count < 20) else {
            return nil
        }
        
        let index = text.index(text.startIndex, offsetBy: 19)
        let value = text.substring(to: index)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        
        if let date = dateFormatter.date(from: value) {
            let seconds = 0 //TimeZone.current.secondsFromGMT()
            return date.addingTimeInterval(TimeInterval(seconds))
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'"
        if let date = dateFormatter.date(from: text) {
            let seconds = 0 //TimeZone.current.secondsFromGMT()
            return date.addingTimeInterval(TimeInterval(seconds))
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
        if let date = dateFormatter.date(from: text) {
            let seconds = 0 //TimeZone.current.secondsFromGMT()
            return date.addingTimeInterval(TimeInterval(seconds))
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.date(from: text) {
            let seconds = 0 //TimeZone.current.secondsFromGMT()
            return date.addingTimeInterval(TimeInterval(seconds))
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        if let date = dateFormatter.date(from: text) {
            let seconds = 0 //TimeZone.current.secondsFromGMT()
            return date.addingTimeInterval(TimeInterval(seconds))
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = dateFormatter.date(from: text) {
            let seconds = 0 //TimeZone.current.secondsFromGMT()
            return date.addingTimeInterval(TimeInterval(seconds))
        }
        
        return nil
    }
}

extension Date{
    var toHHMM : String{
        let dateFormater = DateFormatter()
        dateFormater.timeStyle = .short
        
        return dateFormater.string(from: self)
    }
    
    var toChat: String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < self ? now : self
        let latest = (earliest == now) ? self : now
        let days = calendar.component(.weekday, from: self)
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        let weekDay = days
        let dateFormatter = DateFormatter()
        var day = ""
        
        if components.year! > 0 {
            dateFormatter.dateFormat = "MMM dd,yyyy"
            return dateFormatter.string(from: self)
        }else {
            if calendar.isDateInToday(self) {
                return "Today"
            }else if calendar.isDateInYesterday(self) {
                return "Yesterday"
            }else {
                dateFormatter.dateFormat = " dd, MMM"
                if weekDay == 1 {
                    day = "Sun"
                }else if weekDay == 2 {
                    day = "Mon"
                }else if weekDay == 3 {
                    day = "Tue"
                }else if weekDay == 4 {
                    day = "Wed"
                }else if weekDay == 5 {
                    day = "Thur"
                }else if weekDay == 6 {
                    day = "Fri"
                }else if weekDay == 7 {
                    day = "Sat"
                }else {
                    day = "Day"
                }
                return day + dateFormatter.string(from: self)
            }
        }
    }
    var toConversation: String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < self ? now : self
        let latest = (earliest == now) ? self : now
        let days = calendar.component(.weekday, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        var day = ""
//        let calendar = DateUtils.gregorianCalendar
//        return calendar.ordinalityOfUnit(NSCalendarUnit.CalendarUnitDay,
//                                         inUnit: NSCalendarUnit.CalendarUnitEra, forDate: self)
        let date1 = calendar.startOfDay(for: .now())
        let date2 = calendar.startOfDay(for: self)
        
        let daysCount = calendar.dateComponents([.day], from: date1, to: date2)
        
        if daysCount.day! < -7 {
            dateFormatter.dateFormat = "dd-MM-yyy"
            return dateFormatter.string(from: self)
        }
    
        print ("Days: \(daysCount.day)")
        if calendar.isDateInToday(self) {
            return dateFormatter.string(from: self)
        }else if calendar.isDateInYesterday(self) {
            day = "Yesterday"
            return day
        }else {
            if days == 1 {
                day = "Sunday"
            }else if days == 2 {
                day = "Monday"
            }else if days == 3 {
                day = "Tuesday"
            }else if days == 4 {
                day = "Wednesday"
            }else if days == 5 {
                day = "Thursday"
            }else if days == 6 {
                day = "Friday"
            }else if days == 7 {
                day = "Saturday"
            }else {
                day = "Day"
            }
            return day
        }
    }
    
    
    //    var toReadableDate : String{
    //        get{
    //            let calendar = Calendar.current
    //            let comp = (calendar as NSCalendar).components([.hour, .minute, .day, .month, .year], from: self)
    //
    //            let strHour = String(format: "%02d", comp.hour!)
    //            let strMinute = String(format: "%02d", comp.minute!)
    //
    //            let month = months[comp.month! - 1]
    //
    //            let thisYear = (Calendar.current as NSCalendar).component(.year, from: Date())
    //            let year = comp.year! < thisYear ? "\(String(describing: comp.year!))" : ""
    //
    //            if(Calendar.current.isDateInToday(self)){
    //                return "Today \(strHour):\(strMinute)"
    //            }
    //            else if(Calendar.current.isDateInYesterday(self)){
    //                return "Yesterday \(strHour):\(strMinute)"
    //            }
    //            else{
    //                return "\(String(describing: comp.day!)) \(month) \(year)"
    //            }
    //
    //        }
    //    }
    func timeAgoSinceDate(numericDates: Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < self ? now : self
        let latest = (earliest == now) ? self : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    var toAgo: String {
        return ""
    }
    
    var toUtc: Double {
        return self.timeIntervalSince1970
    }
    
    static func create(from timeInterval: Double) -> Date {
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    static func now() -> Date {
        let seconds = TimeZone.current.secondsFromGMT()
        let d = Date().addingTimeInterval(TimeInterval(seconds))
        return d
    }
    
    
    var toString: String {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        dateFormater.timeStyle = .short
        
        return dateFormater.string(from: self)
    }
    
    var toServer: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS'Z'"
        dateFormater.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormater.string(from: self)
    }
    
    var toServerFormatted: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormater.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormater.string(from: self)
    }
    
    var toServerShort: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        dateFormater.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormater.string(from: self)
    }
    
    var toShort: String {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .long
        dateFormater.doesRelativeDateFormatting = true
        
        return dateFormater.string(from: self)
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) y"   }
        if months(from: date)  > 0 { return "\(months(from: date)) M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) w"   }
        if days(from: date)    > 0 { return "\(days(from: date)) d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date)) h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) s" }
        return ""
    }
    func timeLeft(from date: Date) -> String{
        let calendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.hour, .minute]
        
        let difference = calendar.dateComponents(requestedComponent, from: date, to: self)
        if let hour = difference.hour, hour > 0 {
            if let minute = difference.minute, minute > 0 {
                return "\(hour)h : \(minute)m"
            }else{
                return "\(hour)h"
            }
        }else{
            if let minute = difference.minute, minute > 0 {
                return "\(minute)m"
            }else{
                return "\(String(describing: difference.minute! + 60))m"
            }
        }
    }
}
