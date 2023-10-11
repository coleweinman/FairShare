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
            AmountEntry()
            SingleDropdown(labelName: "Sender")
            SingleDropdown(labelName: "Receiver")
            DateSelector()
        }
    }
}


// Picker for single selection
// Parameter: labelName
struct SingleDropdown: View {
    
    @State private var selectedItem: String = "TODO"
    
    var groupMembers = ["person1", "person2"]
    
    let labelName: String
    
    var body: some View {
        HStack {
            Text(labelName).scenePadding(.all)
            Spacer()
            Picker("Picker Title", selection: $selectedItem) {
                ForEach(groupMembers, id: \.self) {
                    Text($0)
                }
            }.scenePadding(.all)
        }
    }
}
//https://www.swiftyplace.com/blog/swiftui-picker-made-easy-tutorial-with-example
// Picker for date selection
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

// Text fields for entering a dollar amount
struct AmountEntry: View {
    @State var dollarEntry: String = ""
    @State var centsEntry: String = ""
    
    var body: some View {
        HStack{
            Group {
                Text("$")
                TextField("_____", text: $dollarEntry).frame(width: 175, height: 75)
                Text(".")
                TextField("__", text: $centsEntry).frame(width: 80, height: 75)
            }.textFieldStyle(.roundedBorder).font(Font.system(size: 60, design: .default)).padding(.all, 1)

        }
    }
}

struct ExpenseCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseCreationView()
    }
}
