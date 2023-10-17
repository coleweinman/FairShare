//
//  Group.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Group: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var members: [BasicUser]
    var invitedMembers: [BasicUser]
    var involvedUserIds: [String]
    
    func isInvited(userId: String) -> Bool {
        return invitedMembers.contains(where: {u in u.id == userId})
    }
}
