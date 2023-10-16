//
//  User.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var profilePictureUrl: URL?
    var paymentRemindersEnabled: Bool
    var paymentRemindersFrequency: String
    var newExpenseNotificationEnabled: Bool
}

struct UserAmount: Codable, Identifiable {
    var id: String
    var name: String
    var profilePictureUrl: URL?
    var amount: Decimal
}

struct BasicUser: Codable, Identifiable {
    var id: String
    var name: String
    var profilePictureUrl: URL?
}
