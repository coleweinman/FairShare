//
//  ExpensesPageView.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI

enum Sort: CaseIterable, Identifiable {
    var id: Sort { self }
    case date
    case amount
}

struct ExpensesPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var expenseListViewModel = ExpenseListViewModel()
    @State private var isPresented = false
    @State private var ascending = false
    @State private var showDateFilter: Bool = false
    @State private var showAmountFilter: Bool = false
    @State private var showSort: Bool = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var minAmount: String = ""
    @State private var maxAmount: String = ""
    @State private var selectedSort: Sort = .date
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @State private var search: String = ""
    @State private var limit: Int = 5
    
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
                            isPresented.toggle()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .frame(maxHeight: .infinity)
                        .padding(8)
                        .background(cardBackgroundColor)
                        .cornerRadius(cardOuterCornerRadius)
                        .alert(alertMessage, isPresented: $showAlert) {
                            Button("OK", role: .cancel) {
                                isPresented = true
                            }
                        }
                        .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                            // this is the sheet
                            VStack {
                                Text("Filter and Sort")
                                    .bold()
                                    .scenePadding()
                                // TOGGLES
                                VStack {
                                    Toggle("Filter by Date", isOn: $showDateFilter)
                                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    Toggle("Filter by Amount", isOn: $showAmountFilter)
                                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    Toggle("Sort", isOn: $showSort)
                                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                }
                                .scenePadding()
                                // FILTERS
                                // date filter
                                if showDateFilter {
                                    HStack {
                                        VStack {
                                            // start date
                                            Text("Start Date")
                                            DatePicker(
                                                selection: $startDate,
                                                in: ...Date(),
                                                displayedComponents: .date,
                                                label: {}
                                            )
                                            .scenePadding(.horizontal)
                                            .scenePadding([.leading, .trailing, .bottom])
                                        }
                                        VStack {
                                            // end date
                                            Text("End Date")
                                            DatePicker(
                                                selection: $endDate,
                                                in: ...Date(),
                                                displayedComponents: .date,
                                                label: {}
                                            )
                                            .scenePadding(.horizontal)
                                            .scenePadding([.leading, .trailing, .bottom])
                                        }
                                    }
                                }
                                // amount filter
                                if showAmountFilter {
                                    HStack {
                                        VStack {
                                            // min amount
                                            Text("Min Amount")
                                            TextField("0.00", text: $minAmount)
                                                .scenePadding()
                                                .background(Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1))
                                                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                                .scenePadding([.leading, .trailing, .bottom])
                                        }
                                        VStack {
                                            // max amount
                                            Text("Max Amount")
                                            TextField("0.00", text: $maxAmount)
                                                .scenePadding()
                                                .background(Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1))
                                                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                                                .scenePadding([.leading, .trailing, .bottom])
                                        }
                                    }
                                }
                                if showSort {
                                    // SORTS
                                    HStack {
                                        Text("Sort By")
                                        Picker("Sort By", selection: $selectedSort) {
                                            ForEach(Sort.allCases, id: \.self) {sortCase in
                                                Text(sortCase == .date ? "Date" : "Amount")
                                                    .tag(sortCase)
                                            }
                                        }
                                        Button(action: {
                                            ascending.toggle()
                                        }) {
                                            // jesus is 0
                                            // now is a million
                                            Image(systemName: ascending ? "chevron.up" : "chevron.down")
                                                .imageScale(.large)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                // SUBMIT
                                HStack {
                                    // RESET
                                    Button(action: {
                                        showDateFilter = false
                                        showAmountFilter = false
                                        showSort = false
                                        ascending = false
                                        selectedSort = .date
                                    }) {
                                        Text("Reset")
                                    }
                                    .scenePadding()
                                }
                            }
                            Spacer()
                        }
                        TextField("Search", text: $search)
                            .frame(maxHeight: .infinity)
                            .padding(8)
                            .background(cardBackgroundColor)
                            .cornerRadius(cardOuterCornerRadius)
//                        HStack {
//                            Button(action: {
//                                //
//                            }) {
//                                Image(systemName: "chevron.left")
//                            }
//                            Button(action: {
//                                //
//                            }) {
//                                Image(systemName: "chevron.right")
//                            }
//                        }
//                        .frame(maxHeight: .infinity)
//                        .padding(8)
//                        .background(cardBackgroundColor)
//                        .cornerRadius(cardOuterCornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    if let expenses = expenseListViewModel.expenses {
                        VStack {
                            if expenses.count > 0 {
                                ForEach(expenses) { expense in
                                    NavigationLink {
                                        ViewExpensePage(expenseId: expense.id!, canEdit: true)
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
                                // load more
                                if expenses.count >= limit {
                                    Button(action: {
                                        limit += 5
                                        onDismiss()
                                    }) {
                                        Text("Load More")
                                    }
                                    .buttonStyle(.bordered)
                                    .scenePadding()
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
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
                .onAppear() {
                    if let user = userViewModel.user, expenseListViewModel.expenses == nil  {
                        expenseListViewModel.fetchData(uid: user.id!, startDate: nil, endDate: nil, minAmount: nil, maxAmount: nil, sortBy: .date, sortOrder: false, limit: limit)
                    }
                }
            }
        }
    }
    
    // apply the sorts and filters
    func onDismiss() {
        isPresented = false
        
        // validate the amounts
        if showAmountFilter && (!isDouble(amount: minAmount) || !isDouble(amount: maxAmount)) {
            alertMessage = "Enter a valid amount"
            showAlert = true
        // validate the dates
        } else if showDateFilter && (!equalDates(firstDate: startDate, secondDate: endDate) && startDate > endDate) {
            alertMessage = "Enter a valid date range"
            showAlert = true
        }
        let date1 = showDateFilter ? startDate : nil
        let date2 = showDateFilter ? endDate : nil
        let amount1 = showAmountFilter ? Double(minAmount) : nil
        let amount2 = showAmountFilter ? Double(maxAmount) : nil
        let sortBy = selectedSort == .amount ? Sort.amount : Sort.date
        let sortOrder = ascending
        if let user = userViewModel.user {
            expenseListViewModel.fetchData(uid: user.id!, startDate: date1, endDate: date2, minAmount: amount1, maxAmount: amount2, sortBy: sortBy, sortOrder: sortOrder, limit: limit)
        }
    }
    
    func isDouble(amount: String) -> Bool {
        if let _ = Double(amount) {
            return true
        } else {
            return false
        }
    }
    
    func equalDates(firstDate: Date, secondDate: Date) -> Bool {
        let calendar = Calendar.current
        let first = calendar.dateComponents([.year, .month, .day], from: firstDate)
        let second = calendar.dateComponents([.year, .month, .day], from: secondDate)
        return first == second
    }
}

struct ExpensesPageView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesPageView()
    }
}
