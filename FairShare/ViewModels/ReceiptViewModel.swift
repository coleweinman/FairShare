//
//  ReceiptViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 11/14/23.
//

import Foundation
import FirebaseFunctions

class ReceiptViewModel: ObservableObject {
    private lazy var functions = Functions.functions()
    
    func processReceipt(data: Data) async {
        do {
            let result = try await functions.httpsCallable("onProcessReceiptRequest").call(["docId": "IMG_0339 (1).png"])
            if let data = result.data as? [String: Any],
               let data = data["data"] as? [String: Any]
            {
                print(data)
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
        }
    }
}
