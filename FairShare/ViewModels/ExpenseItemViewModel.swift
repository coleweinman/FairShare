//
//  ExpenseItemViewModel.swift
//  FairShare
//
//  Created by Cole Weinman on 11/23/23.
//

import Foundation
class ExpenseItemViewModel: ObservableObject, Identifiable {
    var id = UUID()
    @Published var item: ExpenseItem
    
    init(item: ExpenseItem) {
        self.item = item
    }
}
