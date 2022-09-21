//
//  IncomeCell.swift
//  Home
//
//  Created by Artur Hellmann on 21.09.22.
//

import SwiftUI

struct IncomeCell: View {
    let income: PVIncome?

    var body: some View {
        if let income = income {
            Section("Einnahmen") {
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text(income.today.currencyString)
                            .font(.largeTitle)
                            .foregroundColor(income.today >= 0 ? Color.green : Color.red)
                        Text(income.yesterday.currencyString)
                            .foregroundColor(income.yesterday >= 0 ? Color.green : Color.red)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct IncomeCell_Previews: PreviewProvider {
    static var previews: some View {
        IncomeCell(
            income: PVIncome(today: 13.0, yesterday: -5.0)
        )
    }
}
