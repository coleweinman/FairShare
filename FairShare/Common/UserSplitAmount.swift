//
//  UserSplitAmount.swift
//  FairShare
//
//  Created by Melody Yin on 11/7/23.
//

import SwiftUI

struct UserSplitAmount: View {
    
    // List of all user amounts for liability
    @Binding var currUserAmount: UserAmount
    @State var amount: String = ""
    
    var groupMembers: UserAmountList
    
    var body: some View {
        HStack (alignment: .center){
            ProfileCircleImage(userId: $currUserAmount.id, groupMembers: groupMembers.userAmountsToBasicUser())
            Spacer()
            Text("$").font(Font.system(size: 18, design: .default))
            TextField("", text: $amount).frame(width: 80, height: 60, alignment: .trailing).scenePadding(.all).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
            
        }.textFieldStyle(.roundedBorder).font(Font.system(size: 18, design: .default)).scenePadding()
        .onChange(of: amount) { newVal in
            if let currAmount = Decimal(string: amount) {
                currUserAmount.amount = currAmount
            }
        }.onAppear() {
            if (amount == "" && currUserAmount.amount != 0) {
                amount = "\(currUserAmount.amount)"
            }
        }.onTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }.onChange(of: currUserAmount.amount) { newVal in
            // Allow even split button to override existing values
            amount = "\(currUserAmount.amount)"
        }
    }
}
