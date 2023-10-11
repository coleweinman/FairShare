//
//  PaymentCreationView.swift
//  FairShare
//
//  Created by Melody Yin on 10/10/23.
//

import SwiftUI

struct PaymentCreationView: View {
    var body: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 50)
                AmountEntry()
                DateSelector()
                SingleDropdown(labelName: "Payment From")
                SingleDropdown(labelName: "Payment To")
                ReminderCheckbox(checkboxLabel: "Reminders?")
                SearchBar()
                ButtonStyle1(buttonText:"Attach Transaction\n Confirmation")
                ButtonStyle1(buttonText: "Submit")
            }
        }
    }
}

struct ButtonStyle1: View {
    
    let buttonText: String
    var body: some View {
        Button(buttonText) {
            // What to do on button press
        }.buttonStyle(.bordered).foregroundColor(.white).background(.mint).cornerRadius(10)
    }
}

struct ReminderCheckbox: View {
    let checkboxLabel: String
    
    @State private var setReminders = false
    var body: some View {
        HStack {
            Toggle(isOn: $setReminders) {
                Text(checkboxLabel)
            }.toggleStyle(.switch).padding(.all)
        }
    }
}

struct SearchBar: View {
    
    @State private var searchTerm = ""
    
    var body: some View {
        NavigationStack {
            Text("Test")
        }.searchable(text: $searchTerm, prompt: "Search")
    }
}

struct PaymentCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCreationView()
    }
}
