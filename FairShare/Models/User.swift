//
//  User.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var profilePictureUrl: URL
    var paymentRemindersEnabled: Bool
    var paymentRemindersFrequency: String
    var newExpenseNotificationEnabled: Bool
}

struct UserAmount: Codable {
    var id: String
    var name: String
    var profilePictureUrl: URL
    var amount: Decimal
}

struct BasicUser: Codable {
    var id: String
    var name: String
    var profilePictureUrl: URL
}
