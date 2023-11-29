//
//  ViewExpensePage.swift
//  FairShare
//
//  Created by Melody Yin on 11/25/23.
//

import SwiftUI

struct ViewExpensePage: View {
    
    //@Environment(\.dismiss) private var dismissView
    
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
                    Text(stringAmount).navigationTitle(currExpense.title).font(.system(size: 72, design: .rounded))
                    if (currExpense.description != "") {
                        Text("\"\(currExpense.description)\"").font(.system(size: 18, design: .rounded))
                    }
                    Divider()
                }/*.onAppear() {
                    if let isDeleted = currExpense.isDeleted, isDeleted {
                        expenseViewModel.deleteData(expenseId: expenseId)
                        dismiss()
                    }
                }*/
                HStack {
                    VStack (alignment: .leading) {
                        Text("Paid By").font(.system(size: 18,  weight: .semibold, design: .rounded))
                        HStack (alignment: .top) {
                            PFP(image: currExpense.paidByDetails[0].profilePictureUrl, size: 72)
                            Spacer()
                            Text(currExpense.paidByDetails[0].name).font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        
                        Divider()
                        Text("Members").font(.system(size: 18, weight: .semibold, design: .rounded))
                        VStack (alignment: .leading) {
                            ForEach (currExpense.liabilityDetails) { member in
                                HStack (alignment: .top) {
                                    PFP(image: member.profilePictureUrl, size: 64)
                                    let amount = "\(member.amount)"
                                    Spacer()
                                    VStack (alignment: .trailing){
                                        Text("\(member.name)").padding(.bottom, 5)
                                        Text("$\(amount)")
                                    }
                                }
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
                        ExpenseCreationView(expenseId: expenseId, existingExpense: true)
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
