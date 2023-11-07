//
//  PaymentsPageView.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI

struct PaymentsPageView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var paymentListViewModel = PaymentListViewModel()
    @StateObject private var balanceDataViewModel = BalanceDataViewModel()
    @State private var isPresented = false
    @State private var ascending = true
    @State private var showDateFilter: Bool = false
    @State private var showAmountFilter: Bool = false
    @State private var showPeopleFilter: Bool = false
    @State private var showSort: Bool = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var minAmount: String = ""
    @State private var maxAmount: String = ""
    @State private var selectedSort: Sort = .date
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
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
                    Text("Net Balance")
                        .font(.system(size: headerFontSize, weight: .semibold))
                    if let netBalances = balanceDataViewModel.balanceData?.netBalances {
                        VStack {
                            ForEach(Array(netBalances.keys), id: \.self) { key in
                                NetBalanceView(
                                    user: netBalances[key]!
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(cardPadding)
                        .background(cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    } else {
                        ProgressView()
                    }
                    HStack(spacing: 12) {
                        Button(action: {
                            isPresented.toggle()
                        }) {
                            Spacer()
                            Text("the button that does the thing")
                            Spacer()
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
                                // TOGGLES
                                VStack {
                                    Toggle("Filter by Date", isOn: $showDateFilter)
                                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    Toggle("Filter by Amount", isOn: $showAmountFilter)
                                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                    Toggle("Filter by People", isOn: $showPeopleFilter)
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
                                if showPeopleFilter {
                                    // people filter
                                    HStack {
                                        Text("[the thing to filter by people]")
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
                                        showPeopleFilter = false
                                        showSort = false
                                        ascending = true
                                        selectedSort = .date
                                    }) {
                                        Text("Reset")
                                    }
                                    .scenePadding()
                                }
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    Text("Past Payments")
                        .font(.system(size: headerFontSize, weight: .semibold))
                    if let payments = paymentListViewModel.payments {
                         VStack {
                            ForEach(payments) { payment in
                                NavigationLink {
                                    PaymentCreationView(paymentId: payment.id).navigationTitle("Edit Payment")
                                } label: {
                                    TableCellItemView(
                                        title: "Payment from \(payment.from.name)",
                                        date: payment.date,
                                        amount: payment.amount.moneyString,
                                        pfps: [payment.from.profilePictureUrl],
                                        backgroundColor: Color(red: 0.788, green: 0.894, blue: 0.871, opacity: 0.75),
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
                        paymentListViewModel.fetchData(uid: user.id!)
                        balanceDataViewModel.fetchData(uid: user.id!)
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
        let sortBy = showSort ? selectedSort : nil
        let sortOrder = showSort ? ascending : nil
        if let user = userViewModel.user {
            paymentListViewModel.fetchData(uid: user.id!, startDate: date1, endDate: date2, minAmount: amount1, maxAmount: amount2, involved: nil, sortBy: sortBy, sortOrder: sortOrder)
            print("success")
        } else {
            print("TANKED")
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

struct PaymentsPageView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsPageView()
    }
}
