//
//  EditDevicePrioViewModel.swift
//  Home
//
//  Created by Artur Hellmann on 10.11.22.
//

import Foundation
import SwiftUI

enum EditDeviceListItemType: Identifiable, Equatable {
    static func == (lhs: EditDeviceListItemType, rhs: EditDeviceListItemType) -> Bool {
        switch (lhs, rhs) {
        case let (.device(left), .device(right)):
            return left.identifier == right.identifier
        case let (.batteryLevel(leftLevel, leftIsIndeterminate), .batteryLevel(rightLevel, rightIsIndeterminate)):
            return leftLevel == rightLevel && leftIsIndeterminate == rightIsIndeterminate
        default: return false
        }
    }
    
    var id: String {
        switch self {
        case .device(let info):
            return info.identifier
        case .batteryLevel(let level, _):
            return "theIdent\(level)..."
        }
    }
    
    case device(PVDeviceInfo)
    case batteryLevel(Float, Bool)
}

class EditDevicePrioViewModel: ObservableObject {
    let repo: DataRepository
    
    init(repo: DataRepository, devices: [PVDeviceInfo]) {
        self.repo = repo
        
        var result = devices.map { info in
            EditDeviceListItemType.device(info)
        }
        
        result.append(.batteryLevel(66.5, true))
        result.append(.batteryLevel(33.5, false))
        
        list = result.sorted(by: { left, right in
            let leftPrio: Float
            switch left {
            case .device(let device):
                guard let devicePrio = device.priority else {
                    return false
                }
                leftPrio = Float(devicePrio)
            case .batteryLevel(let level, _):
                leftPrio = level
            }
            let rightPrio: Float
            switch right {
            case let .device(device):
                guard let devicePrio = device.priority else {
                    return false
                }
                rightPrio = Float(devicePrio)
            case .batteryLevel(let level, _):
                rightPrio = level
            }
            return leftPrio > rightPrio
        })
    }
    
    @Published var list: [EditDeviceListItemType] = []
    
    func move(from offset: IndexSet, to destination: Int) {
//        list.move(fromOffsets: offset, toOffset: destination)
        
        print("moving: called this")
        
        let movingObject = list[offset.first!]

        switch movingObject {
        case .device(_):
            list.move(fromOffsets: offset, toOffset: destination)
        case .batteryLevel(_, let isIntermediate):
            let otherIndex = list.firstIndex(of: list.first(where: { item in
                if case let .batteryLevel(_, innerIsIntermediate) = item, isIntermediate != innerIsIntermediate {
                    return true
                }
                return false
            })!)!

            if isIntermediate ? (destination <= otherIndex) : (destination > otherIndex) {
                list.move(fromOffsets: offset, toOffset: destination)
            } else {
                if isIntermediate {
                    list.move(fromOffsets: offset, toOffset: otherIndex)
                } else {
                    list.move(fromOffsets: offset, toOffset: otherIndex + 1)
                }
                list.move(fromOffsets: offset, toOffset: offset.first!)
            }
        }
        
    }
    
    func saveClicked() async throws -> [PVDeviceInfo] {
        
        var deviceListToSave = [PVDeviceInfo]()
        
        var nextItemPrio = 100
        for listItem in list {
            switch listItem {
            case var .device(device):
                device.priority = nextItemPrio
                deviceListToSave.append(device)
                nextItemPrio -= 1
            case let .batteryLevel(_, isItermediate):
                nextItemPrio = isItermediate ? 66 : 33
            }
        }
        
        return try await repo.saveDevicePrios(for: deviceListToSave)
    }
}
