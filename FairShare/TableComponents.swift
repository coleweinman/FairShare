//
//  TableComponents.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI
import FirebaseFunctions
import NukeUI

struct PFP: View {
    var image: URL?
    var size: CGFloat = 32
    
    var body: some View {
        if let profileUrl = image {
            LazyImage(url: profileUrl) { state in
                if let image = state.image {
                    image.resizable()
                } else {
                    ProgressView()
                }
            }
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
}

struct TableCellItemView: View {
    var title: String
    var date: Date?
    var amount: String
    var pfps: [URL?]
    var backgroundColor: Color
    var cornerRadius: CGFloat
    
    var dateFormat: String = "MM / dd / yy"
    var formattedDate: String {
        if let strongDate = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            return dateFormatter.string(from: strongDate)
        }
        return ""
    }
    
    var titleFontSize: CGFloat = 16
    var amountFontSize: CGFloat = 16
    var dateFontSize: CGFloat = 12
    var cardPadding: CGFloat = 16
    var shadowColor: Color = Color.black.opacity(0.2)
    var shadowRadius: CGFloat = 3
    var shadowOffset: CGFloat = 2
    
    var trailingButtonText: String?
    var trailingButtonAction: (() -> Void)?
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(title)
                        .font(.system(size: titleFontSize, weight: .medium))
                    Spacer()
                    Text(String(describing: amount))
                        .font(.system(size: amountFontSize, weight: .medium))
                }
                HStack(alignment: .top) {
                    if formattedDate != "" {
                        Text(formattedDate)
                            .font(.system(size: dateFontSize, weight: .regular))
                    }
                    Spacer()
                    HStack {
                        ForEach(pfps, id: \.self) { pfp in
                            PFP(image: pfp)
                        }
                    }
                }
            }
            if let buttonText = trailingButtonText,
               let buttonAction = trailingButtonAction
            {
                Button(buttonText, action: buttonAction)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(cardPadding)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: shadowColor, radius: shadowRadius, y: shadowOffset)
    }
}

struct NetBalanceView: View {
    var user: UserAmount
    
    var buttonBackgroundColor: Color = Color(red: 0.671, green: 0.827, blue: 0.996)
    var buttonForegroundColor: Color = Color.black
    var buttonPadding: CGFloat = 8
    var buttonSizeRatio: CGFloat = 3
    var buttonCornerRadius: CGFloat = 14
    var shadowColor: Color = Color.black.opacity(0.2)
    var shadowRadius: CGFloat = 3
    var shadowOffset: CGFloat = 2
    var positiveBalanceColor: Color = Color(red: 0.133, green: 0.545, blue: 0.133)
    var negativeBalanceColor: Color = Color(red: 0.843, green: 0.0, blue: 0.251)
    var actionFontSize: CGFloat = 12
    var balanceSpacing: CGFloat = 4
    var nameFontSize: CGFloat = 16
    var balanceFontSize: CGFloat = 16
    
    @State private var remindConfirmationAlert: Bool = false
    
    func remind() async {
        let functionData = ["userId": user.id]
        do {
            let functions = Functions.functions()
            let result = try await functions.httpsCallable("onPaymentReminderRequest").call(functionData)
            if let data = result.data as? [String: Any], let message = data["message"] as? String {
                print(message)
                return
            } else {
                print("Couldn't parse function response!")
                return
            }
        } catch {
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let message = error.localizedDescription
                    print(message)
                    return
                }
                return
            }
        }
    }
    
    var body: some View {
        HStack {
            PFP(image: user.profilePictureUrl, size: 48)
            Text(user.name)
                .font(.system(size: nameFontSize, weight: .medium))
            Spacer()
            VStack(alignment: .center, spacing: balanceSpacing) {
                Text(user.amount.moneyString)
                    .font(.system(size: balanceFontSize, weight: .regular))
                    .foregroundColor(user.amount >= 0 ? positiveBalanceColor : negativeBalanceColor)
                if user.amount > 0 {
                    Button(action: {
                        remindConfirmationAlert = true
                    }) {
                        Text("Remind")
                            .font(.system(size: actionFontSize, weight: .regular))
                            .padding(.vertical, buttonPadding)
                            .padding(.horizontal, buttonPadding * buttonSizeRatio)
                            .foregroundColor(buttonForegroundColor)
                            .background(buttonBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
                            .shadow(color: shadowColor, radius: shadowRadius, y: shadowOffset)
                    }
                }
            }
        }
        .alert(isPresented: $remindConfirmationAlert) {
            Alert(
                title: Text("Payment Reminder"),
                message: Text("Are you sure you want to send a payment reminder to \(user.name)"),
                primaryButton: .default(
                    Text("Send Reminder"),
                    action: {
                        Task {
                            await remind()
                        }
                    }
                ),
                secondaryButton: .cancel()
            )
        }
    }
}
