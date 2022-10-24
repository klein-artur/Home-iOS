//
//  HasTimestamp.swift
//  Home
//
//  Created by Artur Hellmann on 24.10.22.
//

import Foundation

protocol HasTimeInformation {
    var timeInfo: Int { get }
}

extension HasTimeInformation {
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: Double(timeInfo))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
}
