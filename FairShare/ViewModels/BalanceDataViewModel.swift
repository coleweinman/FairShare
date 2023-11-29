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
    
    func sortIds(netBalances: [String: UserAmount]) -> [String] {
        var namesToId: [String: String] = [:]
        var names: [String] = []
        var sortedNames: [String] = []
        var sortedIds: [String] = []
        for id in netBalances.keys {
            let balance = netBalances[id]!
            if balance.amount != 0 {
                let name = balance.name
                namesToId[name] = id
                names.append(name)
            }
        }
        sortedNames = names.sorted()
        for name in sortedNames {
            let id = namesToId[name]
            sortedIds.append(id!)
        }
        return sortedIds
    }
    
    func fetchData(uid: String) {
        var query = db.collection("users").document(uid).collection("secure").document("balances")
        
        var _ = query.addSnapshotListener { documentSnapshot, error in
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
