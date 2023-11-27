//
//  ItemSplitViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 11/14/23.
//

import Foundation
import FirebaseStorage
import FirebaseFunctions

class ItemSplitViewModel: ObservableObject {
    @Published var expenseItems: [ExpenseItemViewModel]
    @Published var loadingReceipt: Bool = false
    
    private lazy var storage = Storage.storage()
    private lazy var functions = Functions.functions()
    
    func processPendingImage(uid: String, data: Data, users: [UserAmount]) async {
        do {
            await MainActor.run {
                loadingReceipt = true
            }
            let imageUuid = UUID()
            let path = "receiptUploads/\(uid)/\(imageUuid).png"
            let imageRef = self.storage.reference(withPath: path)
            try await imageRef.putDataAsync(data)
            try await processReceipt(path: path, users: users)
            await MainActor.run {
                loadingReceipt = false
            }
        } catch {
            print(error)
            await MainActor.run {
                loadingReceipt = false
            }
        }
    }
    
    func processExistingImage(path: String, users: [UserAmount]) async {
        do {
            await MainActor.run {
                loadingReceipt = true
            }
            try await processReceipt(path: path, users: users)
            await MainActor.run {
                loadingReceipt = false
            }
        } catch {
            print(error)
            await MainActor.run {
                loadingReceipt = false
            }
        }
    }
    
    func processReceipt(path: String, users: [UserAmount]) async throws {
        do {
            let result = try await functions.httpsCallable("onProcessReceiptRequest").call(["path": path])
            if let data = result.data as? [String: Any],
               let rawLineItems = data["data"] as? [[String: Any]]
            {
                print(rawLineItems)
                for lineItem in rawLineItems {
                    let name = lineItem["name"] as? String ?? ""
                    let amountStr = lineItem["amount"] as? String ?? ""
                    let amount = Decimal(string: amountStr)
                    let expenseItem = ExpenseItem(name: name, amount: amount ?? 0, split: getSplitDict(users: users))
                    expenseItems.append(ExpenseItemViewModel(item: expenseItem))
                }
            } else {
                print("Couldn't parse function response!")
            }
        } catch {
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("Cloud function error Code:\(code.debugDescription), Message:\(message), Details:\(details ?? "N/A")")
                }
            }
            throw "Error processing receipt"
        }
    }
    
    func getNewUsers(users: [UserAmount]) -> (Decimal, [UserAmount]) {
        var amountDict: [String : Decimal] = [:]
        var total = Decimal(0)
        var applied = Decimal(0)
        for item in expenseItems {
            total += item.item.amount
            let splitAmount = (item.item.amount * 100 / Decimal(item.item.split.count)).rounded(2, .down)
            for uid in item.item.split.keys {
                amountDict.updateValue((amountDict[uid] ?? 0) + splitAmount, forKey: uid)
                applied += splitAmount
            }
        }
        
        var newUsers: [UserAmount] = []
        for user in users {
            let newUser = UserAmount(
                id: user.id,
                name: user.name,
                profilePictureUrl: user.profilePictureUrl,
                amount: amountDict[user.id] ?? 0
            )
            newUsers.append(newUser)
        }
        print(total - applied)
        return (total, newUsers)
    }
    
    init(expenseItems: [ExpenseItemViewModel]) {
        self.expenseItems = expenseItems
    }
}
