//
//  DeviceDetailViewModel.swift
//  Home
//
//  Created by Artur Hellmann on 24.10.22.
//

import SwiftUI

@MainActor
class DeviceDetailViewModel: ObservableObject {
    
    let device: PVDeviceInfo
    let dataRepository: DataRepository
    
    @Published var deviceLog: [PVDeviceLog]?
    
    init (
        device: PVDeviceInfo,
        dataRepository: DataRepository
    ) {
        self.device = device
        self.dataRepository = dataRepository
    }
    
    func loadLog() {
        Task {
            print("Loading device log for \(device.name)")
            do {
                self.deviceLog = try await self.dataRepository.getDeviceLog(identifier: device.identifier)
                print("Done loading device log for \(device.name)")
            } catch {
                print(error)
            }
        }
    }
    
}
