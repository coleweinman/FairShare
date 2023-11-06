//
//  Balances.swift
//  FairShare
//
//  Created by Cole Weinman on 10/24/23.
//

import Foundation
import FirebaseFirestoreSwift

struct BalanceData: Codable {
    var netBalances: [String: UserAmount]
    
    var netBalance: Decimal {
        return netBalances.values.reduce(0) { partialResult, value in
            return partialResult + value.amount
        }
    }
}
