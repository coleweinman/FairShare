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
}
