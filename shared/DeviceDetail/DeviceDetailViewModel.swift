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
            self.name = device.name
            self.estimatedConsumption = device.estimatedConsumption
            
            self.updatePrioButtonEnabled()
            
            if let index = mainViewModel.deviceInfos.firstIndex(where: { $0.identifier == device.identifier }) {
                mainViewModel.deviceInfos[index] = device
            }
        }
    }

    @Published var selectedPrio: Int {
        didSet {
            updatePrioButtonEnabled()
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
    
    @Published var prioButtonEnabled = false
    
    @Published var name: String
    
    @Published var estimatedConsumption: Int
    
    @Published var minOnTime: Int
    
    @Published var minOffTime: Int
    
    private func updatePrioButtonEnabled() {
        prioButtonEnabled = selectedPrio != device.priority && !loading && device(with: selectedPrio) == nil
    }
    
    init (
        device: PVDeviceInfo,
        dataRepository: DataRepository,
        mainViewModel: MainViewModel
    ) {
        self.device = device
        self.isOn = device.isOn
        self.name = device.name
        self.automatic = !device.forced
        self.dataRepository = dataRepository
        self.mainViewModel = mainViewModel
        self.selectedPrio = device.priority!
        self.estimatedConsumption = device.estimatedConsumption
        self.minOnTime = device.minOnTime
        self.minOffTime = device.minOffTime
    }
    
    func device(with prio: Int) -> PVDeviceInfo? {
        mainViewModel.deviceInfos.first { $0.priority == prio && $0.identifier != device.identifier }
    }
    
    func savePriority() {
        self.loading = true
        Task {
            defer {
                Task { @MainActor in
                    self.loading = false
                }
            }
            do {
                guard let newDevice = try await self.dataRepository.saveDevice(with: self.device.identifier, priority: selectedPrio) else {
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
    
    func saveName() {
        self.loading = true
        Task {
            defer {
                Task { @MainActor in
                    self.loading = false
                }
            }
            do {
                guard let newDevice = try await self.dataRepository.changeDevice(with: self.device.identifier, name: name) else {
                    return
                }
                self.device = newDevice
            } catch {
                print(error)
            }
        }
    }
    
    func saveConsumption() {
        self.loading = true
        Task {
            defer {
                Task { @MainActor in
                    self.loading = false
                }
            }
            do {
                guard let newDevice = try await self.dataRepository.changeDevice(with: self.device.identifier, estimated_consumption: estimatedConsumption) else {
                    return
                }
                self.device = newDevice
            } catch {
                print(error)
            }
        }
    }
    
    func saveMinTimes() {
        self.loading = true
        Task {
            defer {
                Task { @MainActor in
                    self.loading = false
                }
            }
            do {
                guard let newDevice = try await self.dataRepository.changeDevice(with: self.device.identifier, minOnTime: minOnTime, minOffTime: minOffTime) else {
                    return
                }
                self.device = newDevice
            } catch {
                print(error)
            }
        }
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
