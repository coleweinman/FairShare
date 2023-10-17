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
        var pictures = Set<URL?>()
        liabilityDetails.forEach { liability in
            pictures.insert(liability.profilePictureUrl)
        }
        paidByDetails.forEach { paidBy in
            pictures.insert(paidBy.profilePictureUrl)
        }
        return Array(pictures)
//        return [URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media")!, URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media")!, URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media")!]
    }
}
