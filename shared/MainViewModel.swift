//
//  File.swift
//  MyPV WatchKit Extension
//
//  Created by Artur Hellmann on 15.08.22.
//

import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {

    @Published var state: PVState?
    @Published var nextHours: [PVNextHour] = []
    @Published var deviceInfos: [PVDeviceInfo] = []
    @Published var income: PVIncome?
    @Published var title: String = ""

    private let dataRepository = DataRepository.shared

    private var timer: Timer?

    init() {
//        self.state = dataRepository.lastStatus
        self.nextHours = dataRepository.lastHours
//        self.deviceLog = dataRepository.lastDeviceLog

        Task {
            await loadState()
        }
        Task {
            await loadNextHours()
        }
        Task {
            await loadDeviceInfos()
        }
        Task {
            await loadIncome()
        }
    }

    func loadState() async {
        print("Starting Task loadState")
        do {
            self.title = "Lädt..."
            self.state = try await self.dataRepository.getStatus()
            self.title = "Verbunden"
        } catch {
            self.title = "Nicht Verbunden"
            print(error)
        }
        _ = Task.delayed(byTimeInterval: 15) {
            await self.loadState()
        }
        print("Task loadState done")
    }

    func loadNextHours() async {
        print("Starting Task loadNextHours")
        do {
            self.nextHours = try await self.dataRepository.getNextHours()
        } catch {
            print(error)
        }
        _ = Task.delayed(byTimeInterval: 15) {
            await self.loadNextHours()
        }
        print("Task loadNextHours done")
    }

    func loadDeviceInfos() async {
        print("Starting Task loadDeviceInfos")
        do {
            self.deviceInfos = try await self.dataRepository.getDeviceInfos(type: "relay")
        } catch {
            print(error)
        }
        _ = Task.delayed(byTimeInterval: 15) {
            await self.loadDeviceInfos()
        }
        print("Task loadDeviceInfos done")
    }

    func loadIncome() async {
        print("Starting Task loadIncome")
        do {
            self.income = try await self.dataRepository.getIncome()
        } catch {
            print(error)
        }
        _ = Task.delayed(byTimeInterval: 15) {
            await self.loadIncome()
        }
        print("Task loadIncome done")
    }

    func startViewModelObservation() {
//        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
////            Task {
////                await self?.loadState()
////            }
////            Task {
////                await self?.loadNextHours()
////            }
////            Task {
////                await self?.loadDeviceInfos()
////            }
////            Task {
////                await self?.loadIncome()
////            }
//        }
    }

}
