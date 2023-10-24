//
//  BalancesViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 10/24/23.
//

import Foundation
import FirebaseFirestore

class BalanceDataViewModel: ObservableObject {
    @Published var balanceData: BalanceData?
    
    private var db = Firestore.firestore()
    
    func fetchData(uid: String) {
        db.collection("users").document(uid).collection("secure").document("balances")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                do {
                    self.balanceData = try document.data(as: BalanceData.self)
                } catch {
                    print("Error fetching document: \(error)")
                }
            }
    }
}
