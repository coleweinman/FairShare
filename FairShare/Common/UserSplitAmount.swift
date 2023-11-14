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
            TextField("_____", text: $amount).frame(width: 50, height: 50, alignment: .trailing)
            
        }.scenePadding()
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
        }
    }
}
