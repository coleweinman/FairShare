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
                TextField("", text: $userInput).scenePadding(.all).shadow(color: shadowColor, radius: 5, x: 0, y: 5).foregroundColor(textColor)
            }.limitInputLength(inputValue: $userInput, length: 8).textFieldStyle(.roundedBorder).font(Font.system(size: 80, design: .default)).padding(.all, 1)
                .onTapGesture() {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding([.leading, .trailing, .top], 20)
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
        } .onTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        } .onChange(of: amount) { newVal in
            userInput = "\(amount)"
            
        }
    }
    
    func isValidMoney() -> Bool {
        let validRegex1 = "^[0-9]*.{1}[0-9]{2}"
        let validRegex2 = "^[0-9]*.*"
        if ((userInput.range(of: validRegex1) != nil) || userInput.range(of: validRegex2) != nil) {
            return true
        }
        return false
    }
}


// https://sanzaru84.medium.com/swiftui-an-updated-approach-to-limit-the-amount-of-characters-in-a-textfield-view-984c942a156
struct TextFieldLimit: ViewModifier {
    @Binding var value: String
    var length: Int
    func body(content: Content) -> some View {
            content
                .onReceive(value.publisher.collect()) {
                    value = String($0.prefix(length))
            }
    }
}

extension View {
    func limitInputLength(inputValue: Binding<String>, length: Int) -> some View {
        self.modifier(TextFieldLimit(value: inputValue, length: length))
    }
}
