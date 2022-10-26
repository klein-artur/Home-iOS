//
//  DeviceDetailView.swift
//  Home
//
//  Created by Artur Hellmann on 24.10.22.
//

import SwiftUI

struct DeviceDetailView: View {
    
    @StateObject var viewModel: DeviceDetailViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24 ) {
                    Text(viewModel.device.isOn ? "AN" : "AUS")
                        .foregroundColor(viewModel.device.isOn ? Color.green : Color.red)
                        .font(.title)
                    HStack {
                        Text("Verbrauch:")
                        Spacer()
                        Text(viewModel.device.consumption?.kwString ?? "")
                    }
                    Toggle(isOn: $viewModel.isOn) {
                        Text("Status:")
                    }
                    .disabled(viewModel.loading)
                    Toggle(isOn: $viewModel.automatic) {
                        Text("Automatik:")
                    }
                    .disabled(viewModel.loading)
                    Divider()
                        .padding(.bottom, 24)
                    if let logs = viewModel.deviceLog {
                        ForEach(logs) { log in
                            VStack {
                                HStack {
                                    Text(log.formattedTime)
                                        .font(.headline)
                                    Spacer()
                                    Text(log.isOn ? "AN" : "AUS")
                                        .foregroundColor(log.isOn ? Color.green : Color.red)
                                }
                                Divider()
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(viewModel.device.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadLog()
        }
    }
}

struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceDetailView(viewModel: DeviceDetailViewModel(device: PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false),dataRepository: DataRepository.shared, mainViewModel: MainViewModel()))
        }
    }
}

extension PVDeviceLog: Identifiable, HasTimeInformation {
    var id: String { "\(identifier)-\(lastChange)" }
    
    var timeInfo: Int { lastChange }
}
