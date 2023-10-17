//
//  ExpenseCreationView.swift
//  FairShare
//
//  Created by Melody Yin on 10/15/23.
//

import SwiftUI
import UIKit

let shadowColor: Color = .gray
let clickableTextColor: Color = .blue


// Variables to hold attributes of created expense
var title:String?
var description: String? //
var date: Date? //
var amount: Decimal? //
var attachmentObjIds: [String]?
var paidBy: String?
var involvedUserIds: [String]?
// Bind attributes to view model


struct ExpenseCreationView: View {
    //@State public var newExpense: Expense?
    //@State public var expenseList: ExpenseViewModel?
    @ObservedObject var viewModel: ExpenseViewModel = ExpenseViewModel()
    @State var expenseAmount: String = ""
    @State var expenseDate: Date = Date()
    @State var expensePayerName: String = ""
    @State var expenseComment: String = ""
    @State var expenseTitle: String = ""
    @State var showAlert = false
    @State var alertMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                //AmountEntry(amount: Binding($viewModel.expense)!.totalAmount)
                AmountEntry(amount: $expenseAmount)
                //ExpenseTitle(title: Binding($viewModel.expense)!.title)
                ExpenseTitle(title: $expenseTitle)
                DateSelector(selectedDate: $expenseDate)
                
                SingleDropdown(labelName: "Paid By", groupMembers: testGroup.members, selectedItem: $expensePayerName)
                MultiSelectNav(options: testGroup.members).padding(.top, 5)
                //ButtonStyle1(buttonText:"Apply Even Split", actionFunction: {self.applyEvenSplit()})
                Divider()
                CommentBox(comment: $expenseComment)
                ButtonStyle1(buttonText:"Attach Receipt", actionFunction: {self.attachReceipt()})
                ButtonStyle1(buttonText: "Submit", actionFunction: {self.createExpenseOnSubmit()}).alert(isPresented: $showAlert) {
                    Alert(title: Text(expenseTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    func attachReceipt() {
        
    }
    func applyEvenSplit() {
        
    }
    
    func createExpenseOnSubmit() {
        if (expenseAmount != "" && expenseTitle != "" && expensePayerName != "") {
            if let amount = Decimal(string: expenseAmount) {
                let newExpense = Expense(title: expenseTitle, description: expenseComment, date: expenseDate, totalAmount: amount, attachmentObjectIds: [], paidByDetails: [], liabilityDetails: [], involvedUserIds: [])
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


struct ExpenseTitle: View {
    @Binding var title: String
    
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Expense Description")
            TextField("Enter title", text: $title).scenePadding(.all).textFieldStyle(.roundedBorder).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
        }.scenePadding()
    }
    
}





// Picker for single selection
// Parameter: labelName
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
                        // Action for set as self button
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
                
            if (selectedItem != "") {
                ProfileCircleImage(userName: $selectedItem)
            }
        }
    }
}

struct ProfileCircleImage: View {
    
    @Binding var userName: String
    var body: some View {
        let user = testUser
        HStack (alignment: .top){
            AsyncImage(url:user.profilePictureUrl){ image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }.frame(width: 50, height: 50).clipShape(Circle()).overlay{ Circle().stroke(.white, lineWidth: 4) }.shadow(radius: 7).padding(.leading, 35)
            Spacer()
            Text(userName).padding(.trailing, 35)
        }.padding([.top, .bottom], -10)
    }
}


    //https://www.swiftyplace.com/blog/swiftui-picker-made-easy-tutorial-with-example
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

struct MultiSelectNav: View {
    
    var options: [BasicUser]
    
    var body: some View {
        NavigationView{
            NavigationLink {
                MemberSelectView(options: options)
            } label: {
                Label("Add Members To Expense", systemImage: "plus")
            }
        }.frame(maxHeight: 40)
        
    }
    
}
struct MemberSelectView: View {

    var options: [BasicUser]
    @State private var multiSelection = Set<UUID>()

    var body: some View {

        NavigationView {
            List(options, selection: $multiSelection) {
                Text($0.name)
            }.navigationTitle("Group Members").toolbar { EditButton() }
        }
        Text("\(multiSelection.count) selections")
    }
}

    
    
    struct ExpenseCreationView_Previews: PreviewProvider {
        static var previews: some View {
            ExpenseCreationView()
        }
    }
