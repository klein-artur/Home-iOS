//
//  EditDevicePrioView.swift
//  Home
//
//  Created by Artur Hellmann on 10.11.22.
//

import SwiftUI

struct EditDevicePrioView: View {
    @EnvironmentObject var mainVieModel: MainViewModel
    @Binding var isShown: Bool
    
    @StateObject var editDevicePrioViewModel: EditDevicePrioViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(editDevicePrioViewModel.list) { item in
                    switch(item) {
                    case .device(let info):
                        deviceView(info: info)
                    case .batteryLevel(_, let isIntermediary):
                        batteryBoundary(isIntermediary: isIntermediary)
                    }
                }
                .onMove { indexSet, destination in
                    editDevicePrioViewModel.move(from: indexSet, to: destination)
                }
            }
            
#if os(iOS)
            .environment(\.editMode, .constant(.active))
#endif
            .toolbar {
                Button("Speichern") {
                    Task { @MainActor in
                        mainVieModel.deviceInfos = try await editDevicePrioViewModel.saveClicked()
                        isShown = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func deviceView(info: PVDeviceInfo) -> some View {
        Text(info.name)
    }
    
    @ViewBuilder
    func batteryBoundary(isIntermediary: Bool) -> some View {
        Text(
            isIntermediary ? "Batterie lädt" : "Batterie lädt voll."
        )
        .foregroundColor(Color.green)
        .font(.system(size: 20, weight: .heavy))
    }
}

struct EditDevicePrioView_Previews: PreviewProvider {
    static var previews: some View {
        EditDevicePrioView(
            isShown: .constant(true),
            editDevicePrioViewModel: EditDevicePrioViewModel(
                repo: .shared,
                devices: [
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 33, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 34, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 66, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 67, estimatedConsumption: 300),
                    PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 99, estimatedConsumption: 300)
                ]
            )
        )
        .environmentObject(MainViewModel())
#if os(iOS)
        .environment(\.editMode, .constant(.active))
#endif
    }
}
