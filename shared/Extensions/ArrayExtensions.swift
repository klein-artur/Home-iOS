//
//  ArrayExtensions.swift
//  Home
//
//  Created by Artur Hellmann on 13.11.22.
//

import Foundation


// MARK: Sorting

extension Array where Element == PVDeviceInfo {
    var prioritySorted: Self {
        self.sorted(by: { left, right in
            guard let leftPrio = left.priority, let rightPrio = right.priority else {
                return false
            }
            return leftPrio > rightPrio
        })
    }
}
