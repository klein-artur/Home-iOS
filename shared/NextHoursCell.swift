//
//  nextHoursCell.swift
//  Home
//
//  Created by Artur Hellmann on 21.09.22.
//

import SwiftUI

struct NextHoursCell: View {

    let nextHours: [PVNextHour]

    var body: some View {
        if nextHours.count == 6 {
            HStack {
                Spacer()
                HStack() {
                    getCircle(for: nextHours[0])
                    getCircle(for: nextHours[1])
                    getCircle(for: nextHours[2])
                    getCircle(for: nextHours[3])
                    getCircle(for: nextHours[4])
                    getCircle(for: nextHours[5])
                }
                .padding([.top, .bottom], 15.0)
                Spacer()
            }
        }
    }

    func getCircle(for hour: PVNextHour) -> some View {
        let color: Color

        #if os(iOS)
        let size: CGFloat = 35.0
        #else
        let size: CGFloat = 20.0
        #endif

        switch hour.state {
        case 0: color = Color.red
        case 1: color = Color.orange
        default: color = Color.green
        }

        return Circle().fill(
            color
        )
            .frame(width: size, height: size)
            .padding([.leading, .trailing], 1.0)
    }
}

struct nextHoursCell_Previews: PreviewProvider {
    static var previews: some View {
        NextHoursCell(
            nextHours: [
                PVNextHour(
                    consumption: 0.2046099999999993,
                    timestamp: 1663758841,
                    maxValue: 4.263,
                    excess: 4.058390000000001,
                    state: 2,
                    percent: 1
                ),
                PVNextHour(
                    consumption: 0.2046099999999993,
                    timestamp: 1663762441,
                    maxValue: 29.304903217551093,
                    excess: 29.100293217551094,
                    state: 2,
                    percent: 1
                ),
                PVNextHour(
                    consumption: 0.2046099999999993,
                    timestamp: 1663766041,
                    maxValue: 46.60394677575785,
                    excess: 46.399336775757845,
                    state: 2,
                    percent: 1
                ),
                PVNextHour(
                    consumption: 0.2046099999999993,
                    timestamp: 1663769641,
                    maxValue: 16.725005679819134,
                    excess: 16.520395679819135,
                    state: 2,
                    percent: 1
                ),
                PVNextHour(
                    consumption: 0.2046099999999993,
                    timestamp: 1663773241,
                    maxValue: 21.639724960085875,
                    excess: 21.435114960085876,
                    state: 2,
                    percent: 1
                ),
                PVNextHour(
                    consumption: 0.2046099999999993,
                    timestamp: 1663776841,
                    maxValue: 28.977262253147714,
                    excess: 28.772652253147715,
                    state: 2,
                    percent: 1
                )
            ]
        )
    }
}
