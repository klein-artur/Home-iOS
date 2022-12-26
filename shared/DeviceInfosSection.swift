//
//  DeviceLogSection.swift
//  Home
//
//  Created by Artur Hellmann on 21.09.22.
//

import SwiftUI

struct DeviceInfosSection: View {
    @EnvironmentObject var mainVieModel: MainViewModel

    let deviceInfo: [PVDeviceInfo]
    
    @State var openPrioEditMode: Bool = false

    var body: some View {
        Section("Geräte") {
            ForEach(deviceInfo) { log in
                NavigationLink {
                    DeviceDetailView(
                        viewModel: DeviceDetailViewModel(
                            device: log,
                            dataRepository: DataRepository.shared,
                            mainViewModel: mainVieModel
                        )
                    )
                } label: {
                    VStack {
                        HStack {
                            Text(log.name)
                                .font(.headline)
                                .padding(.bottom, 6)
                            Spacer()
                            Text(log.isOn ? "AN" : "AUS")
                                .foregroundColor(log.isOn ? Color.green : Color.red)
                        }
                        HStack {
                            Text(log.consumption?.kwString ?? "")
                                .font(.caption)
                            Spacer()
                            Text(log.formattedTime)
                                .font(.caption)
                        }
                    }
                }
            }
            
#if os(iOS)
            Button{
                self.openPrioEditMode = true
            } label: {
                Text("Prioritäten bearbeiten")
            }
            #endif
        }
        .sheet(isPresented: self.$openPrioEditMode) {
            EditDevicePrioView(
                isShown: self.$openPrioEditMode,
                editDevicePrioViewModel: EditDevicePrioViewModel(
                    repo: .shared,
                    devices: deviceInfo
                )
            )
        }
    }
}

struct DeviceLogSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DeviceInfosSection(
                deviceInfo: [
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300)
                ]
            )
            .environmentObject(MainViewModel())
        }
    }
}

extension PVDeviceInfo: Identifiable, HasTimeInformation {
    var id: String { identifier }
    
    var timeInfo: Int { lastChange ?? 0 }
}
