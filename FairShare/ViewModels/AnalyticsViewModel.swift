//
//  AnalyticsViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 11/7/23.
//

import Foundation
import FirebaseFunctions

class AnalyticsViewModel: ObservableObject {
    @Published var totalOwed: [UserAmount]?

    
    private lazy var functions = Functions.functions()
    
    func getData(uid: String) async {
        do {
            let result = try await functions.httpsCallable("onAnalyticsDataRequest").call()
            if let data = result.data as? [String: Any],
               let successData = data["data"] as? [String : Any],
               let totalOwed = successData["totalOwed"] as? [[String : Any]]
            {
                let decoder = JSONDecoder()
                var newTotalOwed: [UserAmount] = []
                for owedData in totalOwed {
                    let data = try JSONSerialization.data(withJSONObject: owedData)
                    let decodedData = try decoder.decode(UserAmount.self, from: data) as UserAmount
                    newTotalOwed.append(decodedData)
                }
                self.totalOwed = newTotalOwed
            } else if let data = result.data as? [String: Any], let message = data["message"] as? String {
                print(message)
            } else if let data = result.data as? [String: Any] {
                print(data)
                print("Couldn't parse function response!")
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
                } else {
                    print(error)
                }
            } else {
                print(error)
            }
        }
    }
}
