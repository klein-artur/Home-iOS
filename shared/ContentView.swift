//
//  ContentView.swift
//  MyPV WatchKit Extension
//
//  Created by Artur Hellmann on 15.08.22.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel = MainViewModel()

    var body: some View {
        NavigationView {
            List {
                NextHoursCell(nextHours: viewModel.nextHours)
                PvCell(state: viewModel.state)
                ConsumptionCell(state: viewModel.state)
                BatteryCell(state: viewModel.state)
                IncomeCell(income: viewModel.income)
                DeviceInfosSection(deviceInfo: viewModel.deviceInfos)
                    .environmentObject(viewModel)
            }
            .refreshable {
                await self.viewModel.loadState()
                await self.viewModel.loadNextHours()
                await self.viewModel.loadDeviceInfos()
                await self.viewModel.loadIncome()
            }
            .onAppear {
                viewModel.startViewModelObservation()
            }
#if os(watchOS)
            .navigationTitle {
                Text(viewModel.title)
            }
#endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
