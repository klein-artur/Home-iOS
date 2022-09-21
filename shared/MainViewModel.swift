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
    @Published var deviceLog: [PVDeviceLog] = []
    @Published var income: PVIncome?
    @Published var title: String = ""

    private let dataRepository = DataRepository.shared

    private var timer: Timer?

    init() {
//        self.state = dataRepository.lastStatus
        self.nextHours = dataRepository.lastHours
//        self.deviceLog = dataRepository.lastDeviceLog

        Task {
            print("Starting Task 1")
            await loadState()
            print("Task 1 done")
        }
        Task {
            print("Starting Task 2")
            await loadNextHours()
            print("Task 2 done")
        }
        Task {
            print("Starting Task 3")
            await loadDeviceLog()
            print("Task 2 done")
        }
        Task {
            print("Starting Task 4")
            await loadIncome()
            print("Task 4 done")
        }
    }

    func loadState() async {
        do {
            self.title = "Lädt..."
            self.state = try await self.dataRepository.getStatus()
            self.title = "Verbunden"
        } catch {
            self.title = "Nicht Verbunden"
            print(error)
        }
    }

    func loadNextHours() async {
        do {
            self.nextHours = try await self.dataRepository.getNextHours()
        } catch {
            print(error)
        }
    }

    func loadDeviceLog() async {
        do {
            self.deviceLog = try await self.dataRepository.getDeviceLog()
        } catch {
            print(error)
        }
    }

    func loadIncome() async {
        do {
            self.income = try await self.dataRepository.getIncome()
        } catch {
            print(error)
        }
    }

    func startViewModelObservation() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task {
                await self?.loadState()
            }
            Task {
                await self?.loadNextHours()
            }
            Task {
                await self?.loadDeviceLog()
            }
            Task {
                await self?.loadIncome()
            }
        }
    }

}
