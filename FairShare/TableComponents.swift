//
//  TableComponents.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI

struct LargePFP: View {
    var image: String
    
    var imageSize: CGFloat = 56
    
    var body: some View {
        Image(image)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize, height: imageSize)
            .clipShape(Circle())
    }
}

struct SmallPFP: View {
    var image: String
    
    var imageSize: CGFloat = 40
    
    var body: some View {
        Image(image)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: imageSize, height: imageSize)
            .clipShape(Circle())
    }
}

struct TableCellItemView: View {
    var title: String
    var date: Date
    var amount: String
    var pfps: [String]
    var backgroundColor: Color
    var cornerRadius: CGFloat
    
    var dateFormat: String = "MM / dd / yy"
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    var titleFontSize: CGFloat = 16
    var amountFontSize: CGFloat = 16
    var dateFontSize: CGFloat = 12
    var cardPadding: CGFloat = 16
    var shadowColor: Color = Color.black.opacity(0.2)
    var shadowRadius: CGFloat = 3
    var shadowOffset: CGFloat = 2
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.system(size: titleFontSize, weight: .medium))
                Spacer()
                Text(String(describing: amount))
                    .font(.system(size: amountFontSize, weight: .medium))
            }
            HStack(alignment: .top) {
                Text(formattedDate)
                    .font(.system(size: dateFontSize, weight: .regular))
                Spacer()
                HStack {
                    ForEach(pfps, id: \.self) { pfp in
                        SmallPFP(image: pfp)
                    }
                }
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
    var pfp: String
    var name: String
    var amount: String
    
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
    
    var body: some View {
        HStack {
            LargePFP(image: pfp)
            Text(name)
                .font(.system(size: nameFontSize, weight: .medium))
            Spacer()
            VStack(alignment: .center, spacing: balanceSpacing) {
                Text(amount)
                    .font(.system(size: balanceFontSize, weight: .regular))
                    .foregroundColor(positiveBalanceColor)
                Button(action: {
                    print("tanked")
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
}
