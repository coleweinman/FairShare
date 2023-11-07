//
//  AmountEntry.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI

// Text fields for entering a dollar amount
struct AmountEntry: View {
    
    @State var userInput: String = ""
    @Binding var amount: Decimal
    @State var textColor: Color = .green
    
    var body: some View {
        VStack (alignment: .center) {
            HStack{
                Text("$")
                TextField("_______", text: $userInput).scenePadding(.all).shadow(color: shadowColor, radius: 5, x: 0, y: 5).foregroundColor(textColor)
            }.textFieldStyle(.roundedBorder).font(Font.system(size: 80, design: .default)).padding(.all, 1)
            Text("Amount")
        }.onChange(of: userInput) { newVal in
            if let currAmount = Decimal(string: userInput) {
                amount = currAmount
                textColor = .green
            } else {
                amount = -1
                textColor = .red
            }
        }.onAppear() {
            if (amount != 0) {
                userInput = "\(amount)"
            }
        }
    }
}
