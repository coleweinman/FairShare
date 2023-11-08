


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
                    .onTapGesture() {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                            // User input for liability amount
                            UserSplitAmount(currUserAmount: $member, groupMembers: expenseMembers).padding([.top, .bottom], 20)
                        }
                    }.onTapGesture() {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    // Comments/ expense description
                    CommentBox(comment: Binding($expenseViewModel.expense)!.description)
                    
                    Divider()
                    Text("Attachments")
                    AttachmentsListView(
                        existingImages: expenseViewModel.expense?.getAttachmentPaths() ?? [],
                        pendingImages: pendingImages, onSelect: { images in pendingImages = images },
                        onRemoveExisting: { index in
                            print(expenseViewModel.expense?.attachmentObjectIds)
                            expenseViewModel.expense?.attachmentObjectIds.remove(at: index)
                            print(expenseViewModel.expense?.attachmentObjectIds)
                        }
                    )
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
                //userAmounts.userAmountList.removeAll(where: { ua in !expenseMembers.contains(where: { em in em.id == ua.id })})
                
                // Create new UserAmount for curr member
                // Set the amount by default to 0
                for member in expenseMembers {
                    if (!userAmounts.userAmountList.contains(where: {$0.id == member.id})) {
                        // Do not have entry for user yet, create
                        userAmounts.userAmountList.append(UserAmount(id: member.id, name: member.name, profilePictureUrl: member.profilePictureUrl, amount: 0.0))
                    }
                }
            }
            .onTapGesture() {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        }.onTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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


// Text field to enter expense title
struct ExpenseTitle: View {
    @Binding var title: String
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Expense Description").scenePadding(.all).padding(.bottom, -30)
            TextField("Enter title", text: $title).scenePadding(.all).textFieldStyle(.roundedBorder).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
        }.scenePadding()
        .onTapGesture() {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

struct ExpenseCreationView_Previews: PreviewProvider {
    
    static var previews: some View {
        ExpenseCreationView()
    }
}

