//
//  ExpenseCreationView.swift
//  FairShare
//
//  Created by Melody Yin on 10/10/23.
//

import SwiftUI

struct ExpenseCreationView: View {
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            SingleDropdown(labelName: "Sender")
            SingleDropdown(labelName: "Receiver")
            DateSelector()
            ButtonTextFieldTest()
        }
    }
}


// Picker for single selection
struct SingleDropdown: View {
    
    @State private var selectedItem: String = "TODO"
    
    var groupMembers = ["person1", "person2"]
    
    let labelName: String
    
    var body: some View {
        HStack (spacing: 180){
            Text(labelName)
            Picker("Picker Title", selection: $selectedItem) {
                ForEach(groupMembers, id: \.self) {
                    Text($0)
                }
            }
        }
    }
}
//https://www.swiftyplace.com/blog/swiftui-picker-made-easy-tutorial-with-example
struct DateSelector: View {
    @State private var selectedDate: Date = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 30) {
            DatePicker("Select a Date", selection: $selectedDate, displayedComponents: .date)
            
            Text("Selected Date: \(selectedDate, formatter: dateFormatter)")
        }.padding()
    }
}

struct ButtonTextFieldTest: View {
    @State var text: String = ""
    
    var body: some View {
        HStack{
            Text("$").font(.largeTitle)
            TextField("Test", text: $text)
        }.padding()
        
    }
}

struct ExpenseCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseCreationView()
    }
}
