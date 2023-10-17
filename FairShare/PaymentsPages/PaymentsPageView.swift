//
//  PaymentsPageView.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI

struct PaymentsPageView: View {
    @StateObject private var userViewModel: UserViewModel = UserViewModel()
    @State private var searchText: String = ""
    
    var pageBackgroundColor: Color = Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1)
    var cardBackgroundColor: Color = Color(red: 1, green: 1, blue: 1, opacity: 1)
    var cardOuterCornerRadius: CGFloat = 24
    var cardPadding: CGFloat = 16
    var headerFontSize: CGFloat = 18
    
    var payments: [Payment] = [
        Payment(id: "1", description: "description", date: Date(), amount: Decimal(54.28), attachmentObjectIds: [], to: UserAmount(id: "1",name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), from: UserAmount(id: "2",name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), involvedUserIds: ["1", "2"]),
        Payment(id: "1", description: "description", date: Date(), amount: Decimal(54.28), attachmentObjectIds: [], to: UserAmount(id: "1",name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), from: UserAmount(id: "2",name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), involvedUserIds: ["1", "2"]),
        Payment(id: "1", description: "description", date: Date(), amount: Decimal(54.28), attachmentObjectIds: [], to: UserAmount(id: "1",name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), from: UserAmount(id: "2",name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), involvedUserIds: ["1", "2"])
    ]
    
    var body: some View {
        ScrollView {
            ZStack {
                Rectangle()
                    .fill(pageBackgroundColor)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack(spacing: 16) {
                    Text("Net Balance")
                        .font(.system(size: headerFontSize, weight: .semibold))
                    VStack {
                        if let user = userViewModel.user {
                            NetBalanceView(pfp: "Weinman", name: user.name, amount: "+ $32.15")
                            NetBalanceView(pfp: "Weinman", name: user.name, amount: "+ $32.15")
                            NetBalanceView(pfp: "Weinman", name: user.name, amount: "+ $32.15")
                        } else {
                            Text("tanked")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    .onAppear() {
                        userViewModel.fetchData(uid: "5xuwvjBzryoJsQ3VGLIX")
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
                    VStack {
                        ForEach(payments) { payment in
                            TableCellItemView(
                                title: "Payment from \(payment.from.name)",
                                date: payment.date,
                                amount: "+ $\(String(describing: payment.amount))",
                                pfps: [payment.from.profilePictureUrl!],
                                backgroundColor: Color(red: 0.788, green: 0.894, blue: 0.871, opacity: 0.75),
                                cornerRadius: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    .onAppear() {
                        userViewModel.fetchData(uid: "5xuwvjBzryoJsQ3VGLIX")
                    }
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
            }
        }
    }
}

struct PaymentsPageView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsPageView()
    }
}
