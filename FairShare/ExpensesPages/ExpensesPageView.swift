//
//  ExpensesPageView.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI

struct ExpensesPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var expenseListViewModel = ExpenseListViewModel()
    @State private var searchText: String = ""
    
    var pageBackgroundColor: Color = Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1)
    var cardBackgroundColor: Color = Color(red: 1, green: 1, blue: 1, opacity: 1)
    var cardOuterCornerRadius: CGFloat = 24
    var cardPadding: CGFloat = 16
    var headerFontSize: CGFloat = 18
    
    var body: some View {
        ScrollView {
            ZStack {
                Rectangle()
                    .fill(pageBackgroundColor)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button(action: {
                            print("tanked")
                        }) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                        .frame(maxHeight: .infinity)
                        .padding(8)
                        .background(cardBackgroundColor)
                        .cornerRadius(cardOuterCornerRadius)
                        TextField("Search...", text: $searchText)
                            .padding(8)
                            .background(cardBackgroundColor)
                            .cornerRadius(cardOuterCornerRadius)
                            .autocapitalization(.none)
                        Button(action: {
                            print("tanked")
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                        .frame(maxHeight: .infinity)
                        .padding(8)
                        .background(cardBackgroundColor)
                        .cornerRadius(cardOuterCornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    if let expenses = expenseListViewModel.expenses {
                        VStack {
                            ForEach(expenses) { expense in
                                NavigationLink {
                                    ExpenseCreationView().navigationTitle("Edit Expense")
                                } label: {
                                    TableCellItemView(
                                        title: expense.title,
                                        date: expense.date,
                                        amount: expense.totalAmount.moneyString,
                                        pfps: expense.profilePictures(),
                                        backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                                        cornerRadius: 8
                                    )
                                }.buttonStyle(PlainButtonStyle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(cardPadding)
                        .background(cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
                .onAppear() {
                    if let user = userViewModel.user {
                        expenseListViewModel.fetchData(uid: user.id!)
                    }
                }
            }
        }
    }
}

struct ExpensesPageView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesPageView()
    }
}
