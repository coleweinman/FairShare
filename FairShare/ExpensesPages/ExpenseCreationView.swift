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

let DEFAULT_EXPENSE = Expense(title: "", description: "", date: Date(), totalAmount: 0.0, attachmentObjectIds: [], paidByDetails: [], liabilityDetails: [], involvedUserIds: [])

// View for expense creation page with all view elements
struct ExpenseCreationView: View {
    // View model to access db and upload new expenses
    @ObservedObject var expenseViewModel: ExpenseViewModel = ExpenseViewModel()
    
    // View Model to access current user logged in
    @EnvironmentObject var userViewModel: UserViewModel
    
    // ToDo: View model to access DB, available groups
    @EnvironmentObject var groupListViewModel: GroupListViewModel
    
    @ObservedObject var groupViewModel: GroupViewModel = GroupViewModel()
    
    @State var expense = DEFAULT_EXPENSE
    
    // State atttributes to store user inputs
    @State var expenseAmount: String = ""
    @State var expenseDate: Date = Date()
    @State var expensePayerId: String = ""
    @State var expenseComment: String = ""
    @State var expenseTitle: String = ""
    @State var showAlert = false
    @State var alertMessage: String = ""
    @State var groupId: String = ""
    // TODO: Set groupMembers based on group selection
    @State var groupMembers: [BasicUser] = []//  = testGroup2.members
    // @State var groupMembers = Set<String>()
    @State var expenseMembers: [BasicUser] = []
    // Don't reload on update of this
    @State var userAmounts: [UserAmount] = []
    
    @State var currUserId: String?
    
    var body: some View {
        ScrollView {
            VStack {
                // Amount
                AmountEntry(amount: $expenseAmount)
                // Title
                ExpenseTitle(title: $expenseTitle)
                // Date
                DateSelector(selectedDate: $expenseDate)
                // Pull choice of groups for logged in user
                if let groups = groupListViewModel.groups {
                    let _ = print(groups.count)
                    // GroupSelect(groups: groups, selectedItem: $groupId, members: $groupMembers)
                    MultiSelectNav(options: groups, involvedUsers: $expenseMembers).padding(.top, 15)
                } else {
                    let _ = print(" NO GROUP OPTIONS")
                    //GroupSelect(groups: [], selectedItem: $groupId, members: $groupMembers)
                }
                // Payer
                // TODO: Use selected group
                // Involved members
                // TODO: fix to use selected group
                // let _ = groupViewModel.fetchData(groupId: groupId)
                //SingleDropdown(labelName: "Paid By", groupMembers: expenseMembers, selectedItem: $expensePayerId)
                if let group = groupViewModel.group {
                    SingleDropdown(labelName: "Paid By", groupMembers: expenseMembers, selectedItem: $expensePayerId)
                    //MultiSelectNav(options: group.members, selections: $groupMembers).padding(.top, 15)
                } else {
                    SingleDropdown(labelName: "Paid By", groupMembers: expenseMembers, selectedItem: $expensePayerId)
                    //MultiSelectNav(options: groupMembers, selections: $groupMembers).padding(.top, 15)
                    /*.onChange(of: groupMembers){ value in
                        for member in groupMembers {
                            // TODO: Make an entry box for each user
                            UserSplitAmount(userAmounts: $userAmounts, user: member)
                        }*/
                    VStack (alignment: .leading) {
                        ForEach(expenseMembers) {member in
                            Spacer()
                            UserSplitAmount(userAmounts: $userAmounts, user: member, groupMembers: expenseMembers).padding([.top, .bottom], 20)
                        }
                    }
                }
                Divider()
                // Comments
                CommentBox(comment: $expenseComment)
                ButtonStyle1(buttonText:"Attach Receipt", actionFunction: {self.attachReceipt()})
                ButtonStyle1(buttonText: "Submit", actionFunction: {self.createExpenseOnSubmit()}).alert(isPresented: $showAlert) {
                    Alert(title: Text(expenseTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }.onAppear() {
                currUserId = userViewModel.user!.id
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
        if (expenseAmount != "" && expenseTitle != "" && expensePayerId != "") {
            if let expenseAmount = Decimal(string: expenseAmount) {
                let newExpense = Expense(title: expenseTitle, description: expenseComment, date: expenseDate, totalAmount: expenseAmount, attachmentObjectIds: [], paidByDetails: [], liabilityDetails: [], involvedUserIds: groupMembers.map{$0.id})
                expenseViewModel.expense = newExpense
                let saveSuccess = expenseViewModel.save()
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

// Segmented view for adding members individually or by group
struct ChooseMemberOption: View {
    @State private var selection = 0
    
    
    var body: some View {
        VStack {
            Picker("Choose member add option", selection: $selection) {
                       Text("Add Group").tag(0)
                       Text("Add Individual Members").tag(1)
                   }.pickerStyle(.segmented)
            if (selection == 0) {
                // Add by group
            } else {
                // Add individual members
            }
         }
    }
    
}

struct UserSplitAmount: View {
    
    @Binding var userAmounts: [UserAmount]
    @State var user: BasicUser
    @State var amount: String = ""
    
    var groupMembers:[BasicUser]
    
    var body: some View {
        HStack (alignment: .top){
            ProfileCircleImage(userId: $user.id, groupMembers: groupMembers)
            Spacer()
            TextField("_____", text: $amount).frame(width: 50, height: 50, alignment: .trailing)
            
        }.scenePadding()
    }
}

// Text field to enter expense title
struct ExpenseTitle: View {
    @Binding var title: String
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Expense Description").scenePadding(.all).padding(.bottom, -30)
            TextField("Enter title", text: $title).scenePadding(.all).textFieldStyle(.roundedBorder).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
        }.scenePadding()
    }
}

// Picker to select group for expense
struct GroupSelect: View {
    @ObservedObject var groupViewModel: GroupViewModel = GroupViewModel()
    //@EnvironmentObject var groupViewModel: GroupViewModel
    
    var groups: [Group]
    @Binding var selectedItem: String
    @State var groupId: String?
    @Binding var members: [BasicUser]
    
    var body: some View {
        let groupNames = groups.map { $0.name }
        HStack(alignment: .center) {
            Text("Group").padding(.leading, 20)
            Spacer()
            Picker("Select", selection: $selectedItem) {
                ForEach(groupNames, id: \.self) {
                    Text($0)
                }
            }.onReceive([self.selectedItem].publisher.first()) { value in
                for group in groups {
                    if (group.name == value) {
                        groupViewModel.fetchData(groupId: selectedItem)
                        groupId = group.id
                        members = group.members
                    }
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
    @EnvironmentObject var userViewModel: UserViewModel
    
    // ID of user selected
    @Binding var selectedItem: String
    
    var body: some View {
        //let memberNames = groupMembers.map { $0.name }
        
        VStack (alignment: .center){
            HStack (alignment: .center) {
                VStack (alignment: .leading){
                    Text(labelName)
                    Button("Set as Self") {
                        // ToDo: Change to use actual name of current user
                        selectedItem = userViewModel.user!.id!
                    }.foregroundColor(clickableTextColor).font(.footnote)
                    // Add HStack with profile picture and name
                }.scenePadding(.all)
                Spacer()
                /*Picker("Select", selection: $selectedItem) {
                    ForEach(memberNames, id: \.self) {
                        Text($0)
                    }
                }*/
                Picker("Select", selection: $selectedItem) {
                    ForEach(groupMembers) { member in
                        Text("\(member.name)")
                    }
                }
                //Text("Selected item: \(selectedItem)")
            }.scenePadding(.all)
            // Update image on picker selection
            if (selectedItem != "") {
                let _ = print("SELECTED ITEM: \(selectedItem)")
                ProfileCircleImage(userId: $selectedItem, groupMembers: groupMembers)
            }
        }
    }
}

// Profile picture + name
struct ProfileCircleImage: View {
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var userId: String
    //@State var user: BasicUser?
    
    let groupMembers: [BasicUser]
    
    //let currUserId: String
    
    /*init(userId: String, groupMembers: [BasicUser]) {
        self.groupMembers = groupMembers
        self.userId = userId
        //self.currUserId = currUserId
    }*/
    
    var body: some View {
        HStack (alignment: .top){
            let currUser = setUser()
            let _ = print("ID OF CURRENT USER: \(currUser.id)")
            AsyncImage(url:currUser.profilePictureUrl){ image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }.frame(width: 50, height: 50, alignment: .leading).clipShape(Circle()).overlay{ Circle().stroke(.white, lineWidth: 4) }.shadow(radius: 7)
            // Spacer()
            Text(currUser.name).padding(.leading, 60)
            
        }.padding([.top, .bottom], -10)
    }
    // If select 'set as self', set to current user logged in
    // Otherwise, hard code to testUser
    func setUser() -> BasicUser {
        if (userId == userViewModel.user!.id) {
            return BasicUser(id: userViewModel.user!.id!, name: userViewModel.user!.name, profilePictureUrl: userViewModel.user!.profilePictureUrl)
        } else {
            for member in groupMembers {
                if member.id == userId {
                    return member
                }
            }
            // TODO: Find correct default, this should not happen
            return BasicUser(id: userViewModel.user!.id!, name: userViewModel.user!.name, profilePictureUrl: userViewModel.user!.profilePictureUrl)
        }
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
    
    // View Model to access current user logged in
    @EnvironmentObject var userViewModel: UserViewModel
    
    var options: [Group]
    // @Binding var selections: [BasicUser]
    @Binding var involvedUsers: [BasicUser]
    
    var body: some View {
        VStack{
            NavigationView{
                NavigationLink {
                    MemberSelectView(groups: options, involvedUsers: $involvedUsers, currUserId: userViewModel.user!.id!)
                } label: {
                    Label("Edit Members On Expense", systemImage: "pencil")
                }
            }.frame(maxHeight: 40)
            Spacer()
        }
        
    }
}

// Multi selection to add members to expense
struct MemberSelectView: View {
    
    struct GroupListItem: Identifiable, Hashable {
        let group: Group
        let id = UUID()
    }
    
    struct UserListItem: Identifiable, Hashable {
        let user: BasicUser
        let id = UUID()
    }
    var groups: [GroupListItem]
    var userOptions: [UserListItem] = []
    @State var multiSelection = Set<UUID>()
    @State private var selection = 0
    //var currUser: User?
    @Binding var involvedUsers: [BasicUser]
    
    @State var editMode = EditMode.active
    @Environment(\.dismiss) private var dismiss
    
    var currUserId: String
    
    init(groups: [Group], involvedUsers: Binding<[BasicUser]>, currUserId: String) {
        self._involvedUsers = involvedUsers
        self.groups = []
        self.userOptions = []
        self.currUserId = currUserId
        //currUser = userViewModel.user
        for group in groups {
            self.groups.append(GroupListItem(group: group))
            print(group.name)
            for user in group.members {
                let currUserItem = UserListItem(user: user)
                // TODO: Check that can unwrap userViewModel, exclude current user
                if (!userOptions.contains(currUserItem) && currUserId != user.id) {
                    print("ADDING USER")
                    self.userOptions.append(currUserItem)
                    print(self.userOptions.count)
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack (alignment: .center){
                Picker("Choose member add option", selection: $selection) {
                           Text("Add By Group").tag(0)
                           Text("Add Individual Members").tag(1)
                       }.pickerStyle(.segmented)
                if (selection == 0) {
                    // Add by group
                    List (groups, selection: $multiSelection){
                        //Text($0.group.name)
                        TableCellItemView(
                            title: $0.group.name,
                            amount: "",
                            pfps: $0.group.members.map {m in m.profilePictureUrl},
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8
                        )
                    }.toolbar {
                        Button("Done") {
                            // Trigger on change for edit mode
                            editMode = EditMode.inactive
                        }.foregroundColor(.blue)
                      }.navigationTitle("Choose a Group")
                } else {
                    // Add individual members
                    let _ = print(userOptions.count)
                    List (userOptions, selection: $multiSelection) {
                        Text($0.user.name)
                    }.toolbar {
                        EditButton()
                    }.navigationTitle("Select Members")
                        .environment(\.editMode, $editMode)
                }
                Text("Selection: \(multiSelection.count)")
                Spacer()
            }.onChange(of: editMode) { newVal in
                print("Clicked done")
                var members: [BasicUser] = []
                if (selection == 0) {
                    // By group
                    for item in multiSelection {
                        print("ITEMS")
                        print(item)
                        // Need to search through groups and userOptions using UUID and return list of users
                        // item is a UUID
                        // Groups
                        let result = groups.filter { $0.id == item}
                        if result.count >= 1 {
                            members.append(contentsOf: result[0].group.members)
                        }
                    }
                } else {
                    // By user
                    for item in multiSelection {
                        print("ITEMS")
                        print(item)
                        // Need to search through groups and userOptions using UUID and return list of users
                        // item is a UUID
                        // Groups
                        let result = userOptions.filter{$0.id == item}
                        if result.count >= 1 {
                            members.append(result[0].user)
                        }
                    }
                    // Add back in current logged in user
                    // TODO: At least 1 group MUST exist --> Put in safeguards for this (check that user is in at least 1 group when starting up creation screen)
                    // Assumption, currUser is a member in all groups in "groups"
                    let someGroup = groups[0].group.members
                    let currUser = someGroup.filter{$0.id == currUserId}
                    members.insert(currUser[0], at: 0)
                }
                involvedUsers = members
                dismiss()
            }
        }
    }
    
    
    /*func removeCurrUser() {
        if let currUser = userViewModel.user {
            for index in userOptions.indices {
                if (userOptions[index].user.id == currUser.id) {
                    userOptions.remove(at: index)
                }
            }
        }
        
        
    }*/
    
}

struct PersonSelection: View {
    
    var userOptions: [UserListItem] = []
    @State var multiSelection = Set<UUID>()
    
    struct UserListItem: Identifiable, Hashable {
        let user: BasicUser
        let id = UUID()
    }
    
    var body: some View {
        Text("Test")
    }
}

struct ExpenseCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseCreationView()
    }
}







struct Test_list: View {
    var array: [String] = ["test", "test2"]
    @State var selected = Set<UUID>()
    @State var isEditing = false
    var body: some View {
        
        NavigationView {
                List {
                    ForEach(array, id: \.self) { item in
                        Text(item)
                    }
                }
                .navigationTitle("Editable List")
                .navigationBarItems(trailing: Button(action: {
                    self.$isEditing.wrappedValue.toggle()
                    if !self.isEditing {
                        
                    }
                }, label: {
                    if self.isEditing {
                        Text("Done")
                    } else {
                        Text("Edit")
                    }
                })).environment(\.editMode, .constant(self.isEditing ? EditMode.active: EditMode.inactive))
            }
    }
}

