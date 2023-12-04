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
    @StateObject var paymentViewModel: PaymentViewModel = PaymentViewModel()
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
    @State private var limit: Int = 5
    @State private var filtersApplied: Bool = false
    
    var pageBackgroundColor: Color = Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1)
    var cardBackgroundColor: Color = Color(red: 1, green: 1, blue: 1, opacity: 1)
    var cardOuterCornerRadius: CGFloat = 24
    var cardPadding: CGFloat = 16
    var headerFontSize: CGFloat = 18
    
    @Environment(\.dismiss) private var dismiss
    
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
                        // send netBalances into a func
                        VStack {
                            if netBalances.count > 0 {
                                ForEach(balanceDataViewModel.sortIds(netBalances: netBalances), id: \.self) { id in
                                    NetBalanceView(user: netBalances[id]!)
                                }
                            } else {
                                Image("duck4")
                                Text("You're all settled up!")
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
                            Image(systemName: "slider.horizontal.3")
                            Text("Show Filters")
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
                            NavigationStack {
                                VStack {
                                    // TOGGLES
                                    VStack {
                                        Toggle("Filter by Date", isOn: $showDateFilter)
                                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                            .onChange(of: showDateFilter) { newValue in
                                                filtersApplied = showDateFilter || showAmountFilter
                                                showAmountFilter = showDateFilter && showAmountFilter ? false : showAmountFilter
                                                if showDateFilter {
                                                    selectedSort = .date
                                                }
                                            }
                                        Toggle("Filter by Amount", isOn: $showAmountFilter)
                                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                            .onChange(of: showAmountFilter) { newValue in
                                                filtersApplied = showDateFilter || showAmountFilter
                                                showDateFilter = showDateFilter && showAmountFilter ? false : showDateFilter
                                                if showAmountFilter {
                                                    selectedSort = .amount
                                                }
                                            }
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
                                            Image(systemName: ascending ? "chevron.up" : "chevron.down")
                                                .imageScale(.large)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    // SUBMIT
                                    HStack {
                                        // RESET
                                        Button(action: {
                                            resetFilters()
                                        }) {
                                            Text("Clear Filters")
                                                .font(.system(size: 20))
                                        }
                                        .scenePadding()
                                    }
                                    Spacer()
                                }
                                .toolbar {
                                    ToolbarItem(placement: .primaryAction, content: {
                                        Button("Done") {
                                            isPresented.toggle()
                                        }
                                    })
                                }
                                .navigationTitle("Filters")
                                .navigationBarTitleDisplayMode(.inline)
                                .presentationDragIndicator(.visible)
                            }
                        }
                        if filtersApplied {
                            Button(action: {
                                resetFilters()
                                onDismiss()
                            }) {
                                Image(systemName: "xmark.circle")
                                Text("Clear Filters")
                            }
                            .frame(maxHeight: .infinity)
                            .padding(8)
                            .background(cardBackgroundColor)
                            .cornerRadius(cardOuterCornerRadius)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    Text("Past Payments")
                        .font(.system(size: headerFontSize, weight: .semibold))
                    if let payments = paymentListViewModel.payments {
                        VStack {
                            if payments.count > 0 {
                                ForEach(payments) { payment in
                                    PaymentCell(payment: payment, userId: userViewModel.user!.id!)
                                }
                                // load more
                                if payments.count >= limit {
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
                                Text("No payments to show!")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(cardPadding)
                        .background(cardBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                        Spacer()
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
                .onAppear() {
                    if let user = userViewModel.user, paymentListViewModel.payments == nil {
                        paymentListViewModel.fetchData(uid: user.id!, startDate: nil, endDate: nil, minAmount: nil, maxAmount: nil, sortBy: .date, sortOrder: false, limit: limit)
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
        } else if (showDateFilter && selectedSort != .date) || (showAmountFilter && selectedSort != .amount) {
            alertMessage = "You cannot filter and sort by different attributes"
            showAlert = true
        }
        let date1 = showDateFilter ? startDate : nil
        let date2 = showDateFilter ? endDate : nil
        let amount1 = showAmountFilter ? Double(minAmount) : nil
        let amount2 = showAmountFilter ? Double(maxAmount) : nil
        let sortBy = selectedSort == .amount ? Sort.amount : Sort.date
        let sortOrder = ascending
        if let user = userViewModel.user {
            paymentListViewModel.fetchData(uid: user.id!, startDate: date1, endDate: date2, minAmount: amount1, maxAmount: amount2, sortBy: sortBy, sortOrder: sortOrder, limit: limit)
        }
    }
    
    func resetFilters() {
        showDateFilter = false
        showAmountFilter = false
        ascending = false
        selectedSort = .date
        filtersApplied = false
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

struct PaymentCell: View {
    let payment: Payment
    let userId: String
    var redbackgroundColor: Color = Color(red: 1.0, green: 0.68, blue: 0.68, opacity: 0.75)
    var greenbackgroundColor: Color = Color(red: 0.788, green: 0.894, blue: 0.871, opacity: 0.75)

       var body: some View {

           return NavigationLink {
               ViewPaymentPage(paymentId: payment.id!, canEdit: true)
           } label: {
               TableCellItemView(
                title: (payment.from.id == userId ? "Payment to \(payment.to.name)" : "Payment from \(payment.from.name)"),
                   date: payment.date,
                   amount: payment.amount.moneyString,
                   pfps: [payment.from.profilePictureUrl],
                   backgroundColor: (payment.from.id == userId ? redbackgroundColor : greenbackgroundColor),
                   cornerRadius: 8
               )
           }
           .buttonStyle(PlainButtonStyle())
       }
   }


