//
//  Timestamp.swift
//  ImageTest
//
//  Created by Gavin Xiang on 2024/4/25.
//

import Foundation

@objcMembers public class Timestamp: NSObject {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
        return formatter
    }()
    
    static func printTimestamp() {
        print(dateFormatter.string(from: Date()))
    }
    
}
