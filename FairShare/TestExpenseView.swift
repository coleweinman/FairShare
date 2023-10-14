//
//  TestExpenseView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import SwiftUI

struct TestExpenseView: View {
    @ObservedObject private var viewModel = ExpenseListViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.expenses) { expense in
                Text(expense.title)
            }
        }
        .onAppear() {
            viewModel.fetchData(uid: "5xuwvjBzryoJsQ3VGLIX")
        }
    }
}

struct TestExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        TestExpenseView()
    }
}
