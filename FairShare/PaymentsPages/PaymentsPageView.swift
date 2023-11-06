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
                    Text("Past Payments")
                        .font(.system(size: headerFontSize, weight: .semibold))
                    if let payments = paymentListViewModel.payments {
                         VStack {
                            ForEach(payments) { payment in
                                NavigationLink {
                                    PaymentCreationView().navigationTitle("Edit Payment")
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
}

struct PaymentsPageView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsPageView()
    }
}
