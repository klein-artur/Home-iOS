//
//  DeviceLogSection.swift
//  Home
//
//  Created by Artur Hellmann on 21.09.22.
//

import SwiftUI

struct DeviceLogSection: View {

    let deviceLog: [PVDeviceLog]

    var body: some View {
        Section("Geräteprotokoll") {
            ForEach(deviceLog) { log in
                VStack {
                    HStack {
                        Text(log.name)
                        Spacer()
                        Text(log.isOn ? "an" : "aus")
                            .foregroundColor(log.isOn ? Color.green : Color.red)
                    }
                    HStack {
                        Text(log.formattedTime)
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct DeviceLogSection_Previews: PreviewProvider {
    static var previews: some View {
        DeviceLogSection(
            deviceLog: [
                PVDeviceLog(identifier: "test", isOn: true, lastChange: 1663761222, name: "Some Testdevice"),
                PVDeviceLog(identifier: "test", isOn: false, lastChange: 1663761222, name: "Some Testdevice"),
                PVDeviceLog(identifier: "test", isOn: false, lastChange: 1663761222, name: "Some Testdevice"),
                PVDeviceLog(identifier: "test", isOn: true, lastChange: 1663761222, name: "Some Testdevice"),
                PVDeviceLog(identifier: "test", isOn: false, lastChange: 1663761222, name: "Some Testdevice"),
                PVDeviceLog(identifier: "test", isOn: true, lastChange: 1663761222, name: "Some Testdevice")
            ]
        )
    }
}

extension PVDeviceLog: Identifiable {
    var id: String { "\(identifier)-\(lastChange)" }

    var formattedTime: String {
        let date = Date(timeIntervalSince1970: Double(lastChange))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }

}
