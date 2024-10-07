//
//  Helper.swift
//  SharePlate
//
//  Created by robert theo on 19/08/24.
//

import Foundation

var defaultTimePickup: Date {
    var components = DateComponents()
    components.year = Calendar.current.component(.year, from: Date())
    components.month = Calendar.current.component(.month, from: Date())
    components.day = Calendar.current.component(.day, from: Date())
    components.hour  = Calendar.current.component(.hour, from: Date()) + 1
    components.minute = Calendar.current.component(.minute, from: Date())
    return Calendar.current.date(from: components) ?? .now
}

let startDate = Date(timeIntervalSinceNow: -24.0 * 3600.0)
let endDate = Date(timeIntervalSinceNow: 24.0 * 3600.0)
