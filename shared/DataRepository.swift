//
//  DataRepository.swift
//  MyPV WatchKit Extension
//
//  Created by Artur Hellmann on 15.08.22.
//

import Foundation
import SwiftUI

typealias DataListener = (PVState) -> Void

struct PVState: Codable {
    let gridOutput: Float
    let batteryCharge: Float
    let pvInput: Float
    let batteryState: Int
    let consumption: Float
    let pvSystemOutput: Float
    let timestamp: Int
}

struct PVNextHour: Codable {
    let consumption: Float
    let timestamp: Int
    let maxValue: Float
    let excess: Float
    let state: Int
    let percent: Float
}

struct PVDeviceLog: Codable {
    let identifier: String
    let isOn: Bool
    let lastChange: Int
    let name: String
}

struct PVIncome: Codable {
    let today: Float
    let yesterday: Float
}

class DataRepository: NSObject {

    static let stateUrl = "\(SERVER_ADRESS)/state.php"
    static let incomeUrl = "\(SERVER_ADRESS)/income.php"
    static let nextHoursUrl = "\(SERVER_ADRESS)/nextHours.php"
    static let deviceLogUrl = "\(SERVER_ADRESS)/deviceLog.php"

    static let LAST_DATA_KEY = "LAST_DATA_KEY"
    static let LAST_HOURS_KEY = "LAST_HOURS_KEY"
    static let LAST_DEVICELOG_KEY = "LAST_DEVICELOG_KEY"
    static let LAST_INCOME_KEY = "LAST_INCOME_KEY"

    static let shared = DataRepository()

    private let defaults: UserDefaults = UserDefaults.standard

    private var timer: Timer?

    var lastStatus: PVState? {
        guard let data = defaults.data(forKey: Self.LAST_DATA_KEY) else {
            return nil
        }
        return try? JSONDecoder().decode(PVState.self, from: data)
    }

    var lastHours: [PVNextHour] {
        guard let data = defaults.data(forKey: Self.LAST_HOURS_KEY) else {
            return []
        }
        return (try? JSONDecoder().decode([PVNextHour].self, from: data)) ?? []
    }

    var lastDeviceLog: [PVDeviceLog] {
        guard let data = defaults.data(forKey: Self.LAST_DEVICELOG_KEY) else {
            return []
        }
        return (try? JSONDecoder().decode([PVDeviceLog].self, from: data)) ?? []
    }

    var lastIncome: PVIncome? {
        guard let data = defaults.data(forKey: Self.LAST_INCOME_KEY) else {
            return nil
        }
        return try? JSONDecoder().decode(PVIncome.self, from: data)
    }

    func getStatus() async throws -> PVState? {
        if let url = URL(string: Self.stateUrl) {
            let (data, _) = try await URLSession.shared.data(from: url) // (try! JSONEncoder().encode(PVState(gridOutput: -0.4055, batteryCharge: 3.978, pvInput: 6.005, batteryState: 66, consumption: 2.4325, pvSystemOutput: 2.027, timestamp: 1660632147)), nil as Any?)

            do {
                let result = try JSONDecoder().decode(PVState.self, from: data)
                defaults.set(data, forKey: Self.LAST_DATA_KEY)
                defaults.synchronize()

                DoOnDataLoadedImpl().doOnDataLoaded()

                return result
            } catch {
                print("Error on server side:")
                print(error)
                return lastStatus
            }
        } else {
            return nil
        }
    }

    func getIncome() async throws -> PVIncome? {
        if let url = URL(string: Self.incomeUrl) {
            let (data, _) = try await URLSession.shared.data(from: url) // (try! JSONEncoder().encode(PVState(gridOutput: -0.4055, batteryCharge: 3.978, pvInput: 6.005, batteryState: 66, consumption: 2.4325, pvSystemOutput: 2.027, timestamp: 1660632147)), nil as Any?)

            do {
                let result = try JSONDecoder().decode(PVIncome.self, from: data)
                defaults.set(data, forKey: Self.LAST_INCOME_KEY)
                defaults.synchronize()

                return result
            } catch {
                print("Error on server side:")
                print(error)
                return lastIncome
            }
        } else {
            return nil
        }
    }

    func getNextHours() async throws -> [PVNextHour] {
        if let url = URL(string: Self.nextHoursUrl) {
            let (data, _) = try await URLSession.shared.data(from: url) // (try! JSONEncoder().encode(PVState(gridOutput: -0.4055, batteryCharge: 3.978, pvInput: 6.005, batteryState: 66, consumption: 2.4325, pvSystemOutput: 2.027, timestamp: 1660632147)), nil as Any?)

            do {
                let result = try JSONDecoder().decode([PVNextHour].self, from: data)
                defaults.set(data, forKey: Self.LAST_HOURS_KEY)
                defaults.synchronize()

                return result
            } catch {
                print("Error on server side:")
                print(error)
                return lastHours
            }
        } else {
            return []
        }
    }

    func getDeviceLog() async throws -> [PVDeviceLog] {
        if let url = URL(string: Self.deviceLogUrl) {
            let (data, _) = try await URLSession.shared.data(from: url) // (try! JSONEncoder().encode(PVState(gridOutput: -0.4055, batteryCharge: 3.978, pvInput: 6.005, batteryState: 66, consumption: 2.4325, pvSystemOutput: 2.027, timestamp: 1660632147)), nil as Any?)

            do {
                let result = try JSONDecoder().decode([PVDeviceLog].self, from: data)
                defaults.set(data, forKey: Self.LAST_DEVICELOG_KEY)
                defaults.synchronize()

                return result
            } catch {
                print("Error on server side:")
                print(error)
                return lastDeviceLog
            }
        } else {
            return []
        }
    }
}

extension Float {
    var kwString: String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        formatter.decimalSeparator = ","


        let number = NSNumber(value: self)
        let formattedValue = formatter.string(from: number)!
        return "\(formattedValue) KW"
    }

    var currencyString: String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.decimalSeparator = ","

        let number = NSNumber(value: self)
        return formatter.string(from: number)!

    }
}

extension Int {
    var pcString: String {
        String(format: "%d %%", self)
    }
}

extension PVState {
    var consumptionColor: Color {
        if consumption / pvSystemOutput < 0.7 {
            return Color.green
        } else if consumption / pvSystemOutput > 1 {
            return Color.red
        } else {
            return Color.orange
        }
    }

    var gridOutputColor: Color {
        if gridOutput < 0 {
            return Color.red
        } else {
            return Color.green
        }
    }

    var pvProportionOfConsumption: Float {
        pvInput - (batteryCharge > 0 ? batteryCharge : 0)
    }

    var pvPercent: Float {
        pvInput / consumption
    }

    var batteryPercent: Float {
        abs(batteryCharge <= 0 ? batteryCharge / consumption : 0.0)
    }

    var gridPercent: Float {
        abs(gridOutput <= 0 ? gridOutput / consumption : 0.0)
    }
}
