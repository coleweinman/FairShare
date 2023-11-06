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
    
    func profilePictures() -> [URL?] {
        var pictures: [URL?] = []
        paidByDetails.forEach { paidBy in
            if let pfpUrl = paidBy.profilePictureUrl {
                if !pictures.contains(pfpUrl) {
                    pictures.append(pfpUrl)
                }
            } else {
                pictures.append(nil)
            }
        }
        liabilityDetails.forEach { liability in
            if let pfpUrl = liability.profilePictureUrl {
                if !pictures.contains(pfpUrl) {
                    pictures.append(pfpUrl)
                }
            } else {
                pictures.append(nil)
            }
        }
        return Array(pictures)
    }
    
    func getAttachmentPaths() -> [String] {
        guard let id = self.id else {
            return []
        }
        return attachmentObjectIds.reduce(into: [String]()) { result, objId in
            result.append("expenseAttachments/\(id)/\(objId)")
        }
    }
}
