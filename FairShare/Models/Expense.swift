//
//  Expense.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Expense: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var date: Date
    var totalAmount: Decimal
    var attachmentObjectIds: [String]
    var paidByDetails: [UserAmount]
    var liabilityDetails: [UserAmount]
    var involvedUserIds: [String]
}
