//
//  DashboardView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI

struct DashboardPageView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var balanceDataViewModel: BalanceDataViewModel
    @StateObject private var paymentListViewModel = PaymentListViewModel()
    @StateObject private var expenseListViewModel = ExpenseListViewModel()
    
    var pageBackgroundColor: Color = Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1)
    var cardBackgroundColor: Color = Color(red: 1, green: 1, blue: 1, opacity: 1)
    var cardOuterCornerRadius: CGFloat = 24
    var cardPadding: CGFloat = 16
    
    var body: some View {
        ScrollView {
            ZStack {
                Rectangle()
                    .fill(pageBackgroundColor)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack(spacing: 16) {
                    Text("Net Balance")
                        .font(.system(size: 16, weight: .semibold))
                    VStack {
                        if let balanceData = balanceDataViewModel.balanceData {
                            if balanceData.netBalance >= 0 {
                                Text(balanceData.netBalance.moneyString)
                                    .font(.system(size: 52, weight: .semibold))
                                    .foregroundColor(Color.green)
                            } else {
                                Text(balanceData.netBalance.moneyString)
                                    .font(.system(size: 52, weight: .semibold))
                                    .foregroundColor(Color.red)
                            }
                            
                        } else {
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    Text("Recent Expenses")
                        .font(.system(size: 16, weight: .semibold))
                    if let expenses = expenseListViewModel.expenses {
                        VStack {
                            if expenses.count > 0 {
                                ForEach(expenses) { expense in
                                    NavigationLink {
                                        // ExpenseCreationView(expenseId: expense.id).navigationTitle("Edit Expense")
                                        ViewExpensePage(expenseId: expense.id!, canEdit: false)
                                    } label : {
                                        TableCellItemView(
                                            title: expense.title,
                                            date: expense.date,
                                            amount: "$\(String(describing: expense.totalAmount))",
                                            pfps: expense.profilePictures(),
                                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                                            cornerRadius: 8
                                        )
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            } else {
                                Image("duck3")
                                Text("You don't have any expenses yet!")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(cardPadding)
                        .background(cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    }
                    Text("Recent Payments")
                        .font(.system(size: 16, weight: .semibold))
                    if let payments = paymentListViewModel.payments {
                        VStack {
                            if payments.count > 0 {
                                ForEach(payments) { payment in
                                    NavigationLink {
                                        ViewPaymentPage(paymentId: payment.id!, canEdit: false)
                                        //PaymentCreationView(paymentId: payment.id).navigationTitle("Edit Payment")
                                    } label: {
                                        TableCellItemView(
                                            title: "Payment from \(payment.from.name)",
                                            date: payment.date,
                                            amount: "+ $\(String(describing: payment.amount))",
                                            pfps: [payment.from.profilePictureUrl],
                                            backgroundColor: Color(red: 0.788, green: 0.894, blue: 0.871, opacity: 0.75),
                                            cornerRadius: 8
                                        )
                                    }.buttonStyle(PlainButtonStyle())
                                }
                            } else {
                                Image("duck3")
                                Text("You don't have any payments yet!")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(cardPadding)
                        .background(cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    }
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
                .onAppear() {
                    if let user = userViewModel.user {
                        expenseListViewModel.fetchData(uid: user.id!, startDate: nil, endDate: nil, minAmount: nil, maxAmount: nil, sortBy: .date, sortOrder: false, limit: 5)
                        paymentListViewModel.fetchData(uid: user.id!, startDate: nil, endDate: nil, minAmount: nil, maxAmount: nil, sortBy: .date, sortOrder: false, limit: 5)
                    }
                }
            }
        }
    }
}

struct DashboardPageView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardPageView()
    }
}
