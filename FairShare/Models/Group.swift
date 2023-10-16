//
//  Group.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import Foundation
import FirebaseFirestoreSwift

struct Group: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var members: [BasicUser]
    var invitedMembers: [BasicUser]
    var involvedUserIds: [String]
}
