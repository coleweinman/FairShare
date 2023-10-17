//
//  ExpenseCreationView.swift
//  FairShare
//
//  Created by Melody Yin on 10/15/23.
//

import SwiftUI
import UIKit

// Hard coded values for view element colors
let shadowColor: Color = .gray
let clickableTextColor: Color = .blue


// Variables to hold attributes of created expense
var title:String?
var description: String?
var date: Date?
var amount: Decimal?
var attachmentObjIds: [String]?
var paidBy: String?
var involvedUserIds: [String]?

// View for expense creation page with all view elements
struct ExpenseCreationView: View {
    // View model to access db and upload new expenses
    @ObservedObject var viewModel: ExpenseViewModel = ExpenseViewModel()
    
    // State atttributes to store user inputs
    @State var expenseAmount: String = ""
    @State var expenseDate: Date = Date()
    @State var expensePayerName: String = ""
    @State var expenseComment: String = ""
    @State var expenseTitle: String = ""
    @State var showAlert = false
    @State var alertMessage: String = ""
    @State var groupName: String = ""
    @State var groupMembers: [BasicUser] = testGroup.members
    
    var body: some View {
        ScrollView {
            VStack {
                // Amount
                AmountEntry(amount: $expenseAmount)
                // Title
                ExpenseTitle(title: $expenseTitle)
                // Date
                DateSelector(selectedDate: $expenseDate)
                // Group: TODO add to expense struct
                GroupSelect(groups: [testGroup], selectedItem: $groupName)
                // Payer
                SingleDropdown(labelName: "Paid By", groupMembers: testGroup.members, selectedItem: $expensePayerName)
                // Involved members
                MultiSelectNav(options: testGroup.members, selections: $groupMembers).padding(.top, 15)
                Divider()
                // Comments
                CommentBox(comment: $expenseComment)
                ButtonStyle1(buttonText:"Attach Receipt", actionFunction: {self.attachReceipt()})
                ButtonStyle1(buttonText: "Submit", actionFunction: {self.createExpenseOnSubmit()}).alert(isPresented: $showAlert) {
                    Alert(title: Text(expenseTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    func attachReceipt() {
        // ToDo: Camera and camera roll launch
    }
    func applyEvenSplit() {
        // ToDO
    }
    
    // Respond to submit button press, use state vars to create and store expense
    func createExpenseOnSubmit() {
        if (expenseAmount != "" && expenseTitle != "" && expensePayerName != "") {
            if let amount = Decimal(string: expenseAmount) {
                let newExpense = Expense(title: expenseTitle, description: expenseComment, date: expenseDate, totalAmount: amount, attachmentObjectIds: [], paidByDetails: [], liabilityDetails: [], involvedUserIds: groupMembers.map{$0.id})
                viewModel.expense = newExpense
                let saveSuccess = viewModel.save()
                if (saveSuccess) {
                    // Successfully saved to DB
                    alertMessage = "Successfully saved expense"
                    showAlert = true
                } else {
                    // Save unsuccessful
                    alertMessage = "Unsuccessful save"
                    showAlert = true
                }
            } else {
                // Invalid amount string
                alertMessage = "Invalid amount"
                showAlert = true
            }
        } else {
            // Some necessary information not given
            alertMessage = "Please fill in all information"
            showAlert = true
        }
    }
}

// Text field to enter expense title
struct ExpenseTitle: View {
    @Binding var title: String
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Expense Description")
            TextField("Enter title", text: $title).scenePadding(.all).textFieldStyle(.roundedBorder).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
        }.scenePadding()
    }
}

// Picker to select group for expense
struct GroupSelect: View {
    
    var groups: [Group]
    @Binding var selectedItem: String
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Group").padding(.leading, 20)
            Spacer()
            Picker("Select", selection: $selectedItem) {
                ForEach(groups, id: \.self) {
                    Text($0.name)
                }
            }
        }.scenePadding(.all)
    }
}

// Picker for single selection of members
struct SingleDropdown: View {
    
    // Parameters: Label for dropdown and list of options
    let labelName: String
    var groupMembers: [BasicUser]
    
    @Binding var selectedItem: String
    
    var body: some View {
        let memberNames = groupMembers.map { $0.name }
        
        VStack (alignment: .center){
            HStack (alignment: .center) {
                VStack (alignment: .leading){
                    Text(labelName)
                    Button("Set as Self") {
                        // ToDo: Change to use actual name of current user
                        selectedItem = "currUser"
                    }.foregroundColor(clickableTextColor).font(.footnote)
                    // Add HStack with profile picture and name
                }.scenePadding(.all)
                Spacer()
                Picker("Select", selection: $selectedItem) {
                    ForEach(memberNames, id: \.self) {
                        Text($0)
                    }
                }
            }.scenePadding(.all)
            // Update image on picker selection
            if (selectedItem != "") {
                ProfileCircleImage(userName: selectedItem)
            }
        }
    }
}

// Profile picture + name
struct ProfileCircleImage: View {
    
    @EnvironmentObject var currUserViewModel: UserViewModel
    
    var userName: String
    var body: some View {
        let user = self.setUser()
        HStack (alignment: .top){
            AsyncImage(url:user.profilePictureUrl){ image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }.frame(width: 50, height: 50).clipShape(Circle()).overlay{ Circle().stroke(.white, lineWidth: 4) }.shadow(radius: 7).padding(.leading, 35)
            Spacer()
            Text(userName).padding(.trailing, 180)
        }.padding([.top, .bottom], -10)
    }
    // If select 'set as self', set to current user logged in
    // Otherwise, hard code to testUser
    func setUser() -> BasicUser {
        if (userName == "currUser") {
            return BasicUser(id: currUserViewModel.user!.id!, name: currUserViewModel.user!.name, profilePictureUrl: currUserViewModel.user!.profilePictureUrl)
        } else {
            return testUser
        }
    }
}

// ToDo: View element for specifying amount liability per involved member
struct UserAmountSelection: View {
    var user: BasicUser
    @Binding var currUserAmount: Decimal
    var body: some View {
        ProfileCircleImage(userName: user.name)
    }
}

// Picker for date selection
struct DateSelector: View {
    @Binding var selectedDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date).padding(.leading, 20)
            Button("Today") {
                selectedDate = Date()
            }.padding(.top, -45).font(.footnote).padding(.leading, 20)
        }.scenePadding().padding(.bottom, -30)
    }
}
    
// Text fields for entering a dollar amount
struct AmountEntry: View {
    @Binding var amount: String
    
    var body: some View {
        VStack (alignment: .center) {
            HStack{
                Text("$")
                TextField("_______", text: $amount).scenePadding(.all).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
            }.textFieldStyle(.roundedBorder).font(Font.system(size: 80, design: .default)).padding(.all, 1)
            Text("Amount")
        }
    }
}

// Navigation to select involved users
struct MultiSelectNav: View {
    
    var options: [BasicUser]
    @Binding var selections: [BasicUser]
    
    var body: some View {
        NavigationView{
            NavigationLink {
                MemberSelectView(options: options, multiSelection: $selections)
            } label: {
                Label("Edit Members On Expense", systemImage: "pencil")
            }
        }.frame(maxHeight: 40)
    }
}

// Multi selection to add members to expense
struct MemberSelectView: View {
    var options: [BasicUser]
    //@State private var multiSelection = Set<UUID>()
    @Binding var multiSelection: [BasicUser]

    var body: some View {
        NavigationView {
            List {
                ForEach(multiSelection) { option in
                    Text(option.name)
                }.onDelete { index in
                    multiSelection.remove(atOffsets: index)
                }
            }.toolbar {
                EditButton()
            }
        }
    }
}

struct ExpenseCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseCreationView()
    }
}
