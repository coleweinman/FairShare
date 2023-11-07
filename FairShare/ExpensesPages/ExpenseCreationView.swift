


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

class UserAmountList: ObservableObject {
    
    @Published var userAmountList: [UserAmount]
    
    init(userAmountList: [UserAmount]) {
        self.userAmountList = userAmountList
    }
    
}

// View for expense creation page with all view elements
struct ExpenseCreationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // View model to access db and upload new expenses
    @StateObject var expenseViewModel: ExpenseViewModel = ExpenseViewModel()
    
    // View Model to access current user logged in
    @EnvironmentObject var userViewModel: UserViewModel
    
    // View model to access DB, available groups
    @EnvironmentObject var groupListViewModel: GroupListViewModel
    
    @StateObject var groupViewModel: GroupViewModel = GroupViewModel()
    
    // Alert attrbutes on submission of expense
    @State var showAlert = false
    @State var alertMessage: String = ""
    
    @State var expensePayerId: String = ""
    @State var expenseMembers: [BasicUser] = []
    @State var userAmounts: UserAmountList = UserAmountList(userAmountList: [])
    
    // Set on appear
    @State var currUserId: String?
    @State var expenseId: String?
    
    @State var pendingImages: [Data] = []
    @State var savingAlert = false
    
    var body: some View {
        ScrollView {
            VStack {
                if (expenseViewModel.expense != nil) {
                    VStack {
                        // Amount
                        AmountEntry(amount: Binding($expenseViewModel.expense)!.totalAmount)
                        // Title
                        ExpenseTitle(title: Binding($expenseViewModel.expense)!.title)
                        // Date
                        DateSelector(selectedDate: Binding($expenseViewModel.expense)!.date)
                    }.onAppear() {
                        // Do rest of initialization for editing here
                        if let currExpense = expenseViewModel.expense {
                            if (expensePayerId == "") {
                                expensePayerId = currExpense.paidByDetails[0].id
                            }
                            if (userAmounts.userAmountList.isEmpty) {
                                userAmounts.userAmountList = currExpense.liabilityDetails
                            }
                            if (expenseMembers.isEmpty) {
                                for user in userAmounts.userAmountList {
                                    expenseMembers.append(BasicUser(id: user.id, name: user.name, profilePictureUrl: user.profilePictureUrl))
                                }
                            }
                        }
                        
                    }
                    // Pull choice of groups for logged in user
                    if let groups = groupListViewModel.groups {
                        MultiSelectNav(options: groups, involvedUsers: $expenseMembers).padding(.top, 15)
                    } else {
                        // Debug print
                        let _ = print(" NO GROUP OPTIONS")
                    }
                    if (!expenseMembers.isEmpty) {
                        // Payer
                        SingleDropdown(labelName: "Paid By", groupMembers: expenseMembers, selectedItem: $expensePayerId)
                        Divider().padding(.top, 20)
                    }
                    // Involved members
                    VStack (alignment: .leading) {
                        ForEach($userAmounts.userAmountList) {$member in
                            Spacer()
                            
                            // TODO: Check that input can be converted to decimal
                            UserSplitAmount(currUserAmount: $member, groupMembers: expenseMembers).padding([.top, .bottom], 20)
                        }
                    }
                    // Comments/ expense description
                    CommentBox(comment: Binding($expenseViewModel.expense)!.description)
                    
                    
                    // TODO: Comment back in
                    Divider()
                    Text("Attachments")
                    AttachmentsListView(existingImages: expenseViewModel.expense?.getAttachmentPaths() ?? [], pendingImages: pendingImages, onSelect: { images in pendingImages = images }, onRemoveExisting: { path in expenseViewModel.expense?.attachmentObjectIds.removeAll(where: { p in p == path }) })
                    Divider()
                    ButtonStyle1(buttonText: "Submit", actionFunction: {
                        Task {
                            await self.createExpenseOnSubmit()
                        }
                    })
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(expenseViewModel.expense!.title), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                } else {
                    ProgressView()
                }
            }.onAppear() {
                currUserId = userViewModel.user!.id
                expensePayerId = currUserId!
                if (expenseId == nil) {
                    // No expenseId given
                    if (expenseViewModel.expense == nil) {
                        expenseViewModel.expense = DEFAULT_EXPENSE
                    }
                } else {
                    expenseViewModel.fetchData(expenseId: expenseId!)
                }
            }.onChange(of: expenseMembers) { newVal in
                
                // Iterate through userAmounts and delete if not in expenseMembers??
                for index in userAmounts.userAmountList.indices {
                    let user = userAmounts.userAmountList[index]
                    if (!expenseMembers.contains(where: {$0.id == user.id})) {
                        userAmounts.userAmountList.remove(at: index)
                    }
                }
                
                // Create new UserAmount for curr member
                // Set the amount by default to 0
                for member in expenseMembers {
                    if (!userAmounts.userAmountList.contains(where: {$0.id == member.id})) {
                        // Do not have entry for user yet, create
                        userAmounts.userAmountList.append(UserAmount(id: member.id, name: member.name, profilePictureUrl: member.profilePictureUrl, amount: 0.0))
                    }
                }
            }
        }.overlay() {
            GeometryReader { geometry in
                if savingAlert {
                    ZStack(alignment: .center) {
                        Color.gray.opacity(0.6).frame(width: geometry.size.width, height: geometry.size.height)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                        VStack {
                            ProgressView()
                            Text("Loading")
                        }
                    }
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
        
        func findSplitSum() -> Decimal {
            var sum: Decimal = 0.0
            for user in userAmounts.userAmountList {
                let currAmount = user.amount
                sum += currAmount
            }
            return sum
        }
        
        // Respond to submit button press, use state vars to create and store expense
        func createExpenseOnSubmit() async {
            if (expenseViewModel.expense!.title != "" && expensePayerId != "") {
                if (expenseViewModel.expense!.totalAmount > 0) {
                    // TODO: Add back in later when user amount update works
                    if (findSplitSum() != expenseViewModel.expense?.totalAmount) {
                     // Liability amounts don't sum to expense amount
                     alertMessage = "Sum of dues does not equal expense"
                     showAlert = true
                     return
                     }
                    let paidByUser = expenseMembers.filter{$0.id == expensePayerId}[0]
                    let paidByAmount = UserAmount(id: paidByUser.id, name: paidByUser.name, amount: expenseViewModel.expense!.totalAmount)
                    expenseViewModel.expense?.paidByDetails = [paidByAmount]
                    expenseViewModel.expense?.liabilityDetails = userAmounts.userAmountList
                    expenseViewModel.expense?.involvedUserIds = expenseMembers.map{$0.id}
                    
                    // TODO: Comment back in
                    await MainActor.run {
                        self.savingAlert = true
                    }
                    expenseViewModel.expense?.date = Date.now
                    let saveSuccess = await expenseViewModel.saveWithAttachments(attachments: pendingImages)
                    
                    await MainActor.run {
                        self.savingAlert = false
                        alertMessage = saveSuccess
                        showAlert = true
                        if (saveSuccess == "Expense saved successfully") {
                            // Successfully saved to DB
                            showAlert = true
                            dismiss()
                        }
                    }
                    
                } else {
                    // Invalid amount
                    alertMessage = "Invalid amount"
                    showAlert = true
                }
            } else {
                // Some necessary information not given
                alertMessage = "Please fill in all information"
                showAlert = true
            }
        }
    } // End of ExpenseCreationView()



struct UserSplitAmount: View {
    
    // List of all user amounts for liability
    @Binding var currUserAmount: UserAmount
    // User amount associated with this view: TODO set this
    //@Binding var currUserAmount: UserAmount
    // BasicUser associated with this view
    //@State var user: BasicUser
    @State var amount: String = ""
    
    var groupMembers:[BasicUser]
    
    var body: some View {
        HStack (alignment: .top){
            ProfileCircleImage(userId: $currUserAmount.id, groupMembers: groupMembers)
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
        }
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
    
    @State var userInput: String = ""
    @Binding var amount: Decimal
    @State var textColor: Color = .green
    
    var body: some View {
        VStack (alignment: .center) {
            HStack{
                Text("$")
                TextField("_______", text: $userInput).scenePadding(.all).shadow(color: shadowColor, radius: 5, x: 0, y: 5).foregroundColor(textColor)
            }.textFieldStyle(.roundedBorder).font(Font.system(size: 80, design: .default)).padding(.all, 1)
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
            for user in group.members {
                let currUserItem = UserListItem(user: user)
                // TODO: Check that can unwrap userViewModel, exclude current user
                if (!userOptions.contains(currUserItem) && currUserId != user.id) {
                    self.userOptions.append(currUserItem)
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
                var members: [BasicUser] = []
                if (selection == 0) {
                    // By group
                    for item in multiSelection {
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
    
}

struct PersonSelection: View {
    
    var userOptions: [UserListItem]
    @State var multiSelection = Set<UUID>()
    
    @State var editMode = EditMode.active
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedUsers: [BasicUser]
    
    struct UserListItem: Identifiable, Hashable {
        let user: BasicUser
        let id = UUID()
    }
    init(userOptions: [BasicUser], selectedUsers: Binding<[BasicUser]>) {
        self._selectedUsers = selectedUsers
        self.userOptions = []
        for user in userOptions {
            self.userOptions.append(UserListItem(user: user))
        }
    }
    
    var body: some View {
        NavigationView {
            List (userOptions, selection: $multiSelection) {
                Text($0.user.name)
            }.toolbar {
                EditButton()
            }.navigationTitle("Select Members")
                .environment(\.editMode, $editMode)
            Text("Selection: \(multiSelection.count)")
            Spacer()
        }.onChange(of: editMode) { newVal in
            var members: [BasicUser] = []
                // By user
                for item in multiSelection {
                    // Need to search through groups and userOptions using UUID and return list of users
                    // item is a UUID
                    // Groups
                    let result = userOptions.filter{$0.id == item}
                    if result.count >= 1 {
                        members.append(result[0].user)
                    }
                }
                selectedUsers = members
                dismiss()
        }
    }
}

/*struct test: View {
    @State var testUsers: [BasicUser] = []
    
    var body: some View {
        PersonSelection(userOptions: userList, selectedUsers: $testUsers)
    }
}*/


struct ExpenseCreationView_Previews: PreviewProvider {
    
    static var previews: some View {
        ExpenseCreationView()
    }
}

