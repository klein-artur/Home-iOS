//
//  DeviceLogSection.swift
//  Home
//
//  Created by Artur Hellmann on 21.09.22.
//

import SwiftUI

struct DeviceInfosSection: View {

    let deviceInfo: [PVDeviceInfo]

    var body: some View {
        Section("Geräte") {
            ForEach(deviceInfo) { log in
                NavigationLink {
                    DeviceDetailView(
                        viewModel: DeviceDetailViewModel(
                            device: log,
                            dataRepository: DataRepository.shared
                        )
                    )
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.name)
                                .font(.headline)
                                .padding(.bottom, 6)
                            Text(log.consumption?.kwString ?? "")
                                .font(.caption)
                        }
                        Spacer()
                        Text(log.isOn ? "AN" : "AUS")
                            .foregroundColor(log.isOn ? Color.green : Color.red)
                    }
                }
            }
        }
    }
}

struct DeviceLogSection_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfosSection(
            deviceInfo: [
                PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice"),
                PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice"),
                PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice"),
                PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice"),
                PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice"),
                PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice")
            ]
        )
    }
}

extension PVDeviceInfo: Identifiable, HasTimeInformation {
    var id: String { identifier }
    
    var timeInfo: Int { lastChange ?? 0 }
}
