//
//  DeviceDetailViewModel.swift
//  Home
//
//  Created by Artur Hellmann on 24.10.22.
//

import SwiftUI

@MainActor
class DeviceDetailViewModel: ObservableObject {
    
    private var locked = false
    private let mainViewModel: MainViewModel
    
    @Published var device: PVDeviceInfo {
        didSet {
            self.locked = true
            self.isOn = device.isOn
            self.automatic = !device.forced
            self.locked = false
            
            if let index = mainViewModel.deviceInfos.firstIndex(where: { $0.identifier == device.identifier }) {
                mainViewModel.deviceInfos[index] = device
            }
        }
    }
    
    @Published var isOn: Bool {
        didSet {
            guard !locked else { return }
            self.locked = true
            self.loading = true
            Task {
                defer {
                    Task { @MainActor in
                        self.locked = false
                        self.loading = false
                    }
                }
                do {
                    guard let newDevice = try await self.dataRepository.switchDevice(with: self.device.identifier, on: self.isOn) else {
                        self.isOn = !self.isOn
                        return
                    }
                    self.device = newDevice
                } catch {
                    self.isOn = !self.isOn
                    print(error)
                }
            }
        }
    }
    
    @Published var automatic: Bool {
        didSet {
            guard !locked else { return }
            self.locked = true
            self.loading = true
            Task {
                defer {
                    Task { @MainActor in
                        self.locked = false
                        self.loading = false
                    }
                }
                do {
                    guard let newDevice = try await self.dataRepository.switchDeviceMode(with: self.device.identifier, manual: !self.automatic) else {
                        self.automatic = !self.automatic
                        return
                    }
                    self.device = newDevice
                } catch {
                    self.automatic = !self.automatic
                    print(error)
                }
            }
        }
    }
    
    let dataRepository: DataRepository
    
    @Published var deviceLog: [PVDeviceLog]?
    
    @Published var loading = false
    
    init (
        device: PVDeviceInfo,
        dataRepository: DataRepository,
        mainViewModel: MainViewModel
    ) {
        self.device = device
        self.isOn = device.isOn
        self.automatic = !device.forced
        self.dataRepository = dataRepository
        self.mainViewModel = mainViewModel
    }
    
    func loadLog() {
        self.deviceLog = []
//        Task {
//            print("Loading device log for \(device.name)")
//            do {
//                self.deviceLog = try await self.dataRepository.getDeviceLog(identifier: device.identifier)
//                print("Done loading device log for \(device.name)")
//            } catch {
//                print(error)
//            }
//        }
    }
    
}
