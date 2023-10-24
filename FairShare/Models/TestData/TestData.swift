//
//  TestData.swift
//  FairShare
//
//  Created by Melody Yin on 10/17/23.
//

import Foundation

let testUser = BasicUser(id: "5xuwvjBzryoJsQ3VGLIX", name: "Cole Weinman", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media")! )

let testUser2 = BasicUser(id: "6789", name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fairshare-project.appspot.com/o/profilePictures%2FwQYRiaB1rTeXt6War1AVz87ZXnb2.jpg?alt=media&token=8f3ff497-a7f4-4df7-bc45-a1eb4f8c0be9")!)

let testUser3 = BasicUser(id:"54321", name: "Emily", profilePictureUrl: URL(string: "https://url.com")!)

let testUser4 = BasicUser(id: "QmQzNS2JgCaMYoPxldBR6PzryRQ2", name: "Bill Bulko", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fairshare-project.appspot.com/o/profilePictures%2FQmQzNS2JgCaMYoPxldBR6PzryRQ2.jpg?alt=media&token=a67f1905-be2c-4a34-9ed9-f7e395577cdf")!)


// Mock data for group members
var userList: [BasicUser] = [
    testUser,
    testUser2,
    testUser3,
    testUser4
]

var pendingMembers: [BasicUser] = [
    BasicUser(id: "1357", name: "Arthur", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FsampleProfile1.png?alt=media&token=fd0728c8-9bc0-411c-ab6a-3fe80531ae57&_gl=1*7g5n3t*_ga*MTAyMjQ5MTE2OC4xNjk2NTE5MjM4*_ga_CW55HF8NVT*MTY5NzU1ODE0MS43LjEuMTY5NzU1OTUyNy4zOC4wLjA.")!),
    BasicUser(id: "7531", name: "Daily", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FsampleProfile3.png?alt=media&token=264af5f1-7ee6-47a7-9819-bfc61a6dc97a&_gl=1*9ad0sc*_ga*MTAyMjQ5MTE2OC4xNjk2NTE5MjM4*_ga_CW55HF8NVT*MTY5NzU1ODE0MS43LjEuMTY5NzU1OTU1OC43LjAuMA..")!)
]

// For payments
let testUserAmount = BasicUser(id: "12345", name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media")!)
let testUserAmount2 = BasicUser(id: "54321", name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/fairshare-project.appspot.com/o/profilePictures%2FwQYRiaB1rTeXt6War1AVz87ZXnb2.jpg?alt=media&token=8f3ff497-a7f4-4df7-bc45-a1eb4f8c0be9")!)

let testGroup = Group(name: "Roomies", members: userList, invitedMembers: pendingMembers, involvedUserIds: userList.map {$0.id})

let testGroup2 = Group(name: "My favorite students", members: userList, invitedMembers: pendingMembers, involvedUserIds: userList.map {$0.id})

let testGroupNames = userList.map{$0.name}
