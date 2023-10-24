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
}
