//
//  ShoppingList.swift
//  FairShare
//
//  Created by Cole Weinman on 10/24/23.
//

import Foundation
import FirebaseFirestoreSwift

struct ShoppingList: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var name: String
    var groupId: String?
    var users: [BasicUser]
    var involvedUserIds: [String]
    var items: [ListItem]
    var createDate: Date
    var lastEditDate: Date
}

struct ListItem: Codable, Equatable {
    var name: String
    var checked: Bool
}

struct IndexedListItem: Identifiable, Hashable, Equatable {
    var id: Int { index }
    var index: Int
    var name: String
    var checked: Bool
}
