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

    @Published var data: PVState?
    @Published var title: String = ""

    private let dataRepository = DataRepository.shared

    private var timer: Timer?

    init() {
        Task {
            await loadData()
        }
    }

    func loadData() async {
        do {
            self.title = "Lädt..."
            self.data = try await self.dataRepository.getStatus()
            self.title = "Verbunden"
        } catch {
            self.title = "Nicht Verbunden"
            print(error)
        }
    }

    func startViewModelObservation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task {
                await self?.loadData()
            }
        }
    }

}
