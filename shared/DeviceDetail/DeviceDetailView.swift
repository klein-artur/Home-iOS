//
//  DeviceDetailView.swift
//  Home
//
//  Created by Artur Hellmann on 24.10.22.
//

import SwiftUI

struct DeviceDetailView: View {
    
    @StateObject var viewModel: DeviceDetailViewModel
    
    @State var changeName: Bool = false
    @State var changeConsumption: Bool = false
    @State var changeMinTimes: Bool = false
    
    var body: some View {
        ZStack {
            Form {
                Section("Info") {
                    HStack {
                        Text("KW:")
                        Spacer()
                        Text(viewModel.device.consumption?.kwString ?? "")
                    }
                    HStack {
                        Text("Uhrzeit, Datum:")
                        Spacer()
                        Text(viewModel.device.formattedTime)
                    }
                }
                Section("Steuerung") {
                    Toggle(isOn: $viewModel.isOn) {
                        Text("Status:")
                    }
                    .disabled(viewModel.loading)
                    Toggle(isOn: $viewModel.automatic) {
                        Text("Automatik:")
                    }
                    .disabled(viewModel.loading)
                    
                    #if os(watchOS)
//                    HStack {
//                        Picker("Priorität:", selection: $viewModel.selectedPrio) {
//                            ForEach(0...100, id: \.self) {
//                                if let deviceWithSamePrio = viewModel.device(with: $0) {
//                                    Text("\($0) \(deviceWithSamePrio.name)")
//                                        .lineLimit(1)
//                                        .tag($0)
//                                } else {
//                                    Text("\($0)")
//                                        .tag($0)
//                                }
//                            }
//                        }
//                        .padding(.trailing, 20)
//                        .disabled(viewModel.loading)
//                        Button("Speichern") {
//                            viewModel.savePriority()
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .disabled(!viewModel.prioButtonEnabled)
//                    }
                    #endif
                }
//                Section {
//                    if let logs = viewModel.deviceLog {
//                        ForEach(logs) { log in
//                            VStack {
//                                HStack {
//                                    Text(log.formattedTime)
//                                        .font(.headline)
//                                    Spacer()
//                                    Text(log.isOn ? "AN" : "AUS")
//                                        .foregroundColor(log.isOn ? Color.green : Color.red)
//                                }
//                                Divider()
//                            }
//                        }
//                    } else {
//                        ProgressView()
//                    }
//                }
                Section("System") {
                    HStack {
                        Text("ID:")
                        Spacer()
                        Text(viewModel.device.identifier)
                    }
                }
                #if os(iOS)
                Section("Steuerung") {
                    Button("Name Ändern") {
                        changeName = true
                    }
                    .disabled(viewModel.loading)
                    Button("Verbrauch Ändern") {
                        changeConsumption = true
                    }
                    .disabled(viewModel.loading)
                    Button("Minimal Zeiten Ändern") {
                        changeMinTimes = true
                    }
                    .disabled(viewModel.loading)
                }
                #endif
            }
        }
        .navigationTitle(viewModel.device.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadLog()
        }
        .alert("Name Ändern", isPresented: $changeName) {
            TextField("Name", text: $viewModel.name)
            Button("Abbrechen", role: .cancel, action: {})
            Button("Speichern") {
                viewModel.saveName()
            }
        }
        .alert("Verbrauch Ändern", isPresented: $changeConsumption) {
            #if os(iOS)
            TextField("Verbrauch", value: $viewModel.estimatedConsumption, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            #endif
            Button("Abbrechen", role: .cancel, action: {})
            Button("Speichern") {
                viewModel.saveConsumption()
            }
        }
        .alert("Verbrauch Ändern", isPresented: $changeMinTimes) {
            #if os(iOS)
            TextField("Minimal On Time", value: $viewModel.minOnTime, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            TextField("Minimal Off Time", value: $viewModel.minOffTime, formatter: NumberFormatter())
                .keyboardType(.numberPad)
            #endif
            Button("Abbrechen", role: .cancel, action: {})
            Button("Speichern") {
                viewModel.saveMinTimes()
            }
        }
    }
}

struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceDetailView(viewModel: DeviceDetailViewModel(device: PVDeviceInfo(identifier: "Test", isOn: true, lastChange: 1663761222, consumption: 1.1, temperature: nil, name: "Some Testdevice", forced: false, priority: 10, estimatedConsumption: 300, minOnTime: 1000, minOffTime: 1000),dataRepository: DataRepository.shared, mainViewModel: MainViewModel()))
        }
    }
}

extension PVDeviceLog: Identifiable, HasTimeInformation {
    var id: String { "\(identifier)-\(lastChange)" }
    
    var timeInfo: Int { lastChange }
}
