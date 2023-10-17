//
//  TestData.swift
//  FairShare
//
//  Created by Melody Yin on 10/17/23.
//

import Foundation

let testUser = BasicUser(id: "12345", name: "Cole Wienman", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media")! )


// Mock data for group members
var userList: [BasicUser] = [
    BasicUser(id: "12345", name: "John", profilePictureUrl: URL(string: "https://url.com")!),
    BasicUser(id: "6789", name: "Jane", profilePictureUrl: URL(string: "https://url.com")!),
    BasicUser(id:"54321", name: "Emily", profilePictureUrl: URL(string: "https://url.com")!)
]

var pendingMembers: [BasicUser] = [
    BasicUser(id: "1357", name: "Daisy", profilePictureUrl: URL(string: "https://url.com")!),
    BasicUser(id: "7531", name: "Arthur", profilePictureUrl: URL(string: "https://url.com")!)
]

// For payments
let testUserAmount = UserAmount(id: "12345", name: "John", profilePictureUrl: URL(string: "https://url.com")!, amount: 12.99)
let testUserAmount2 = UserAmount(id: "54321", name: "Jane", profilePictureUrl: URL(string: "https://url.com")!, amount: 12.99)

let testGroup = Group(name: "Roomies", members: userList, invitedMembers: pendingMembers, involvedUserIds: userList.map {$0.id})

let testGroupNames = userList.map{$0.name}
