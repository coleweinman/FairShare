//
//  DashboardView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI

struct DashboardPageView: View {
    
    var payments: [Payment] = [
        Payment(id: "1", description: "description", date: Date(), amount: Decimal(54.28), attachmentObjectIds: [], to: UserAmount(id: "1",name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), from: UserAmount(id: "2",name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), involvedUserIds: ["1", "2"]),
        Payment(id: "1", description: "description", date: Date(), amount: Decimal(54.28), attachmentObjectIds: [], to: UserAmount(id: "1",name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), from: UserAmount(id: "2",name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), involvedUserIds: ["1", "2"]),
        Payment(id: "1", description: "description", date: Date(), amount: Decimal(54.28), attachmentObjectIds: [], to: UserAmount(id: "1",name: "Cole", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), from: UserAmount(id: "2",name: "Andrew", profilePictureUrl: URL(string: "https://firebasestorage.googleapis.com/v0/b/fairshare-project.appspot.com/o/profilePictures%2FGPFP.png?alt=media"), amount: Decimal(50.0)), involvedUserIds: ["1", "2"])
    ]
    
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
                        Text("$0.00")
                            .font(.system(size: 52, weight: .semibold))
                            .foregroundColor(Color.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    Text("Recent Expenses")
                        .font(.system(size: 16, weight: .semibold))
                    VStack {
                        TableCellItemView(
                            title: "Dinner at Roadhouse",
                            date: Date(),
                            amount: "$\(String(describing: 105.39))",
                            pfps: [],
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8)
                        TableCellItemView(
                            title: "Dinner at North Italia",
                            date: Date(),
                            amount: "$\(String(describing: 217.11))",
                            pfps: [],
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    Text("Recent Payments")
                        .font(.system(size: 16, weight: .semibold))
                    VStack {
                        ForEach(payments) { payment in
                            TableCellItemView(
                                title: "Payment from \(payment.from.name)",
                                date: payment.date,
                                amount: "+ $\(String(describing: payment.amount))",
                                pfps: [],
                                backgroundColor: Color(red: 0.788, green: 0.894, blue: 0.871, opacity: 0.75),
                                cornerRadius: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
            }
        }
    }
    }

struct DashboardPageView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardPageView()
    }
}
