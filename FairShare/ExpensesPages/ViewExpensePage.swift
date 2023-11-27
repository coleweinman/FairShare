//
//  ViewExpensePage.swift
//  FairShare
//
//  Created by Melody Yin on 11/25/23.
//

import SwiftUI

struct ViewExpensePage: View {
    
    // View model to access db and upload new expenses
    @StateObject var expenseViewModel: ExpenseViewModel = ExpenseViewModel()
    // Passed expenseID
    // Need to lookup expense with expenseViewModel
    
    // var currExpense: Expense
    var expenseId: String
    
    var canEdit: Bool
    var body: some View {
        VStack {
            if let currExpense = expenseViewModel.expense {
                VStack (alignment: .center) {
                    Divider()
                    let stringAmount = "$\(currExpense.totalAmount)"
                    Text(stringAmount).navigationTitle(currExpense.title).font(.system(size: 64, design: .rounded))
                    if (currExpense.description != "") {
                        Text("\"\(currExpense.description)\"").font(.system(size: 18, design: .rounded))
                    }
                    Divider()
                }
                HStack {
                    VStack (alignment: .leading) {
                        Text("Paid By").font(.system(size: 18,  weight: .semibold, design: .rounded))
                        HStack (alignment: .top) {
                            PFP(image: currExpense.paidByDetails[0].profilePictureUrl, size: 64)
                            Spacer()
                            Text(currExpense.paidByDetails[0].name).font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        
                        Divider()
                        Text("Members").font(.system(size: 18, weight: .semibold, design: .rounded))
                        HStack {
                            ForEach (currExpense.liabilityDetails) { member in
                                PFP(image: member.profilePictureUrl, size: 64)
                            }
                        }
                        Divider()
                        
                        HStack {
                            Text("Date of Purchase").font(.system(size: 18,  weight: .semibold, design: .rounded))
                            let dateFormatter = DateFormatter()
                            let _ = dateFormatter.dateStyle = .long
                            Spacer()
                            Text(dateFormatter.string(from: currExpense.date)).font(.system(size: 18, design: .rounded))
                        }.padding(.top)
                        
                    }
                    Spacer()
                }
                // TODO: Add button to view receipt
                Spacer()
            }
            
        }.toolbar {
            if (canEdit) {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        // Action
                        ExpenseCreationView(expenseId: expenseId)
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                }
            }
        }.onAppear() {
            expenseViewModel.fetchData(expenseId: expenseId)
        }.padding()
    }
    
}

//#Preview {
    // ViewExpensePage()
//}
