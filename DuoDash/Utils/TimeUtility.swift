//
//  TimeUtility.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import Foundation

struct TimeResult {
    public let totalSeconds: Int
    public let minutes: Int
    public let hours: Int
    public let days: Int
    public let months: Int
    public let years: Int
}


func timeSince(date: Date) -> TimeResult {
    let now = Date()
    let calendar = Calendar.current
    
    let totalSeconds = Int(now.timeIntervalSince(date))
    let minutes = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0
    let hours = calendar.dateComponents([.hour], from: date, to: now).hour ?? 0
    let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
    let months = calendar.dateComponents([.month], from: date, to: now).month ?? 0
    let years = calendar.dateComponents([.year], from: date, to: now).year ?? 0
    
    
    return TimeResult(totalSeconds: totalSeconds, minutes: minutes, hours: hours, days: days, months: months, years: years)
}


func timeSinceCombined(since date: Date) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full // Options: .positional, .abbreviated, .short, .full
    formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
    formatter.maximumUnitCount = 6 // How many units to show (e.g., set to 2 for "1 year, 3 months")
    
    let now = Date()
    return formatter.string(from: date, to: now) ?? ""
}
