//
//  ViewExpensePage.swift
//  FairShare
//
//  Created by Melody Yin on 11/25/23.
//

import SwiftUI

struct ViewExpensePage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    // View model to access db and upload new expenses
    @StateObject var expenseViewModel: ExpenseViewModel = ExpenseViewModel()
    // Passed expenseID
    // Need to lookup expense with expenseViewModel
    
    // var currExpense: Expense
    var expenseId: String
    
    @State var showConfirmationDialogue = false
    
    var canEdit: Bool
    var body: some View {
        ScrollView {
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
                    }
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
                                        //let amount = "\(member.amount)"
                                        let amount = (member.amount as NSDecimalNumber).doubleValue
                                        Spacer()
                                        VStack (alignment: .trailing){
                                            let formattedAmount = String(format: "%.2f", amount)
                                            Text("\(member.name)").padding(.bottom, 5)
                                            Text("$\(formattedAmount)")
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
                    Divider()
                    Text("Attachments").font(.system(size: 18,  weight: .semibold, design: .rounded))
                    ForEach(currExpense.getAttachmentPaths(), id: \.self) { url in
                        StorageImageView(path: url, maxWidth: 300, maxHeight: 300)
                    }
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
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            // Open confirmation of delete with ok and cancel
                            showConfirmationDialogue.toggle()
                        } label: {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                    }
                }
            }.confirmationDialog("Confirm deletion", isPresented: $showConfirmationDialogue) {
                Button("Confirm") { // Call delete
                    expenseViewModel.deleteData(expenseId: expenseId)
                    self.presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Delete expense?")
            }
            .onAppear() {
                expenseViewModel.fetchData(expenseId: expenseId)
            }.padding()
        }
    }
    
    
    func formattedCurrency(amount: String) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .currency
        return formatter.string(for: amount) ?? "0"
    }
    
}

//#Preview {
    // ViewExpensePage()
//}
