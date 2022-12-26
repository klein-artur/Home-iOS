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

struct PVDeviceInfo: Codable {
    let identifier: String
    let isOn: Bool
    let lastChange: Int?
    let consumption: Float?
    let temperature: Float?
    let name: String
    let forced: Bool
    var priority: Int?
    let estimatedConsumption: Int
}

struct PVIncome: Codable {
    let today: Float
    let yesterday: Float
}

struct PVSwitchResult: Codable {
    let result: Bool
    let output: String?
}

class DataRepository: NSObject {
    
    static let stateEndpoint = "state.php"
    static let incomeEndpoint = "income.php"
    static let nextHoursEndpoint = "nextHours.php"
    static let deviceLogEndpoint = "deviceLog.php"
    static let deviceInfosEndpoint = "deviceInfos.php"
    static let deviceSwitchEndpoint = "switchDevice.php"
    static let devicePrioEndpoint = "changeDevicePrio.php"
    static let devicePriosEndpoint = "changeDevicePrios.php"
    static let deviceChangeEndpoint = "changeDevice.php"

    static let LAST_DATA_KEY = "LAST_DATA_KEY"
    static let LAST_HOURS_KEY = "LAST_HOURS_KEY"
    static let LAST_DEVICELOG_KEY = "LAST_DEVICELOG_KEY"
    static let LAST_INCOME_KEY = "LAST_INCOME_KEY"
    static let LAST_DEVICEINFOS_KEY = "LAST_DEVICEINFOS_KEY"

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
    
    var lastDeviceInfos: [PVDeviceInfo] {
        guard let data = defaults.data(forKey: Self.LAST_DEVICEINFOS_KEY) else {
            return []
        }
        return (try? JSONDecoder().decode([PVDeviceInfo].self, from: data)) ?? []
    }

    func getStatus() async throws -> PVState? {
        if let request = getRequest(endpoint: Self.stateEndpoint, method: .get) {
            let (data, _) = try await URLSession.shared.data(for: request)
            do {
                let result = try JSONDecoder().decode(PVState.self, from: data)
                defaults.set(data, forKey: Self.LAST_DATA_KEY)
                defaults.synchronize()

                DoOnDataLoadedImpl().doOnDataLoaded()

                return result
            } catch {
                print("Error on server side in getStatus:")
                print(error)
                return lastStatus
            }
        } else {
            return nil
        }
    }

    func getIncome() async throws -> PVIncome? {
        if let request = getRequest(endpoint: Self.incomeEndpoint, method: .get) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVIncome.self, from: data)
                defaults.set(data, forKey: Self.LAST_INCOME_KEY)
                defaults.synchronize()

                return result
            } catch {
                print("Error on server side in getIncome:")
                print(error)
                return lastIncome
            }
        } else {
            return nil
        }
    }

    func getNextHours() async throws -> [PVNextHour] {
        if let request = getRequest(endpoint: Self.nextHoursEndpoint, method: .get) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode([PVNextHour].self, from: data)
                defaults.set(data, forKey: Self.LAST_HOURS_KEY)
                defaults.synchronize()

                return result
            } catch {
                print("Error on server side in getNextHours:")
                print(error)
                return lastHours
            }
        } else {
            return []
        }
    }

    func getDeviceLog(identifier: String) async throws -> [PVDeviceLog] {
        if let request = getRequest(endpoint: Self.deviceLogEndpoint, method: .get, params: ["identifier": identifier]) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode([PVDeviceLog].self, from: data)
                defaults.set(data, forKey: Self.LAST_DEVICELOG_KEY)
                defaults.synchronize()

                return result
            } catch {
                print("Error on server side in getDeviceLog:")
                print(error)
                return lastDeviceLog
            }
        } else {
            return []
        }
    }
    
    func getDeviceInfos(type: String) async throws -> [PVDeviceInfo] {
        if let request = getRequest(endpoint: Self.deviceInfosEndpoint, method: .get, params: ["type": type]) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode([PVDeviceInfo].self, from: data)

                return result.prioritySorted
            } catch {
                print("Error on server side in getDeviceInfos:")
                print(error)
                return []
            }
        } else {
            return []
        }
    }
    
    func getDeviceInfo(identifier: String) async throws -> PVDeviceInfo? {
        if let request = getRequest(endpoint: Self.deviceInfosEndpoint, method: .get, params: ["identifier": identifier]) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVDeviceInfo.self, from: data)

                return result
            } catch {
                print("Error on server side in getDeviceInfo:")
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    func switchDevice(with identifier: String, on: Bool) async throws -> PVDeviceInfo? {
        let params = [
            "identifier": identifier,
            "type": "switch",
            "value": on ? "on" : "off"
        ]
        if let request = getRequest(endpoint: Self.deviceSwitchEndpoint, method: .post, params: params) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVSwitchResult.self, from: data)
                
                if result.result {
                    return try await getDeviceInfo(identifier: identifier)
                } else {
                    print(result.output)
                    return nil
                }
            } catch {
                print("Error on server side in getDeviceInfo:")
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    func switchDeviceMode(with identifier: String, manual: Bool) async throws -> PVDeviceInfo? {
        let params = [
            "identifier": identifier,
            "type": "mode",
            "value": manual ? "on" : "off"
        ]
        if let request = getRequest(endpoint: Self.deviceSwitchEndpoint, method: .post, params: params) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVSwitchResult.self, from: data)
                
                if result.result {
                    return try await getDeviceInfo(identifier: identifier)
                } else {
                    print(result.output)
                    return nil
                }
            } catch {
                print("Error on server side in getDeviceInfo:")
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    func saveDevice(with identifier: String, priority: Int) async throws -> PVDeviceInfo? {
        let params = [
            "identifier": identifier,
            "prio": "\(priority)"
        ]
        if let request = getRequest(endpoint: Self.devicePrioEndpoint, method: .post, params: params) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVSwitchResult.self, from: data)
                
                if result.result {
                    return try await getDeviceInfo(identifier: identifier)
                } else {
                    print(result.output)
                    return nil
                }
            } catch {
                print("Error on server side in getDeviceInfo:")
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func changeDevice(with identifier: String, field: String, value: String) async throws -> PVDeviceInfo? {
        let params = [
            "identifier": identifier,
            field: value
        ]
        if let request = getRequest(endpoint: Self.deviceChangeEndpoint, method: .post, params: params) {
             let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVSwitchResult.self, from: data)
                
                if result.result {
                    return try await getDeviceInfo(identifier: identifier)
                } else {
                    print(result.output)
                    return nil
                }
            } catch {
                print("Error on server side in getDeviceInfo:")
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    func changeDevice(with identifier: String, name: String) async throws -> PVDeviceInfo? {
        try await self.changeDevice(with: identifier, field: "name", value: name)
    }
    
    func changeDevice(with identifier: String, estimated_consumption: Int) async throws -> PVDeviceInfo? {
        try await self.changeDevice(with: identifier, field: "estimated_consumption", value: "\(estimated_consumption)")
    }
    
    func saveDevicePrios(for devices: [PVDeviceInfo]) async throws -> [PVDeviceInfo] {
        let params = devices.reduce([String: String]()) { partialResult, device in
            var partialResult = partialResult
            partialResult[device.identifier] = "\(device.priority!)"
            return partialResult
        }
        if let request = getRequest(endpoint: Self.devicePriosEndpoint, method: .post, params: params) {
            let (data, _) = try await URLSession.shared.data(for: request)

            do {
                let result = try JSONDecoder().decode(PVSwitchResult.self, from: data)
                
                if result.result {
                    return try await getDeviceInfos(type: "relay")
                } else {
                    return []
                }
            } catch {
                print("Error on server side in getDeviceInfo:")
                print(error)
                return []
            }
        } else {
            return []
        }
    }
    
    private func getRequest(endpoint: String, method: Method, params: [String: String] = [:]) -> URLRequest? {
        
        guard var url = URL(string: "\(SERVER_ADRESS)/\(endpoint)") else {
            return nil
        }
        
        if method == .get {
            url.append(
                queryItems: params.map({ key, value in
                    URLQueryItem(name: key, value: value)
                })
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method == .post {
            request.httpBody = params.percentEncoded()
        }
        
        let authData = (BASIC_AUTH_USER + ":" + BASIC_AUTH_PASSWORD).data(using: .utf8)!.base64EncodedString()
        request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
        
        return request
        
    }
    
    enum Method: String {
        case post = "POST"
        case get = "GET"
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

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
