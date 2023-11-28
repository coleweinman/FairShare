//
//  Payment.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Payment: Codable, Identifiable {
    @DocumentID var id: String?
    var description: String
    var date: Date
    var amount: Decimal
    var attachmentObjectIds: [String]
    var to: BasicUser
    var from: BasicUser
    var involvedUserIds: [String]
    
    func setPaymentTitle(currUser: BasicUser) -> String {
        if (currUser.id == self.to.id) {
            // Payment to current user
            return "Incoming Payment"
        } else {
            return "Outgoing Payment"
        }
    }
}
