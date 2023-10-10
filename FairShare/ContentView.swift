//
//  ContentView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/5/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Text("Tanked")
            SingleDropdown()
            DateSelector()
        }
        .padding()
    }
}


// Picker for single selection
struct SingleDropdown: View {
    
    @State private var selectedItem: String = "TODO"
    
    var groupMembers = ["person1", "person2"]
    
    var body: some View {
        Picker("Picker Title", selection: $selectedItem) {
            ForEach(groupMembers, id: \.self) {
                Text($0)
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
