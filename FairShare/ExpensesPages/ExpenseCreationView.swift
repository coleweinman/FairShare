


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
// let expenseBackgroundColor: Color = Color(red: 0.671, green: 0.827, blue: 0.996)
let expenseBackgroundColor: Color = .white

let DEFAULT_EXPENSE = Expense(title: "", description: "", date: Date(), totalAmount: 0.0, attachmentObjectIds: [], paidByDetails: [], liabilityDetails: [], involvedUserIds: [])

class UserAmountList: ObservableObject {
    
    @Published var userAmountList: [UserAmount]
    
    init(userAmountList: [UserAmount]) {
        self.userAmountList = userAmountList
    }
    
    func basicUsersToUserAmounts(users: [BasicUser]) -> [UserAmount] {
        var result: [UserAmount] = []
        for user in users {
            result.append(UserAmount(id: user.id, name: user.name, profilePictureUrl: user.profilePictureUrl, amount: 0.0))
        }
        return result
    }
    
    func userAmountsToBasicUser() -> [BasicUser] {
        var result: [BasicUser] = []
        for amount in self.userAmountList {
            result.append(BasicUser(id: amount.id, name: amount.name, profilePictureUrl: amount.profilePictureUrl))
        }
        return result
    }
    
    func applyEvenSplit(total: Decimal) {
        var splitAmount = total / Decimal(self.userAmountList.count)
        // Round to 2 decimal places
        // Calculate leftover cents and add 1 cent for leftover amount of people
        for index in self.userAmountList.indices {
            self.userAmountList[index].amount = splitAmount
            print("NEW AMOUNT: ", self.userAmountList[index].amount)
        }
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
    // @State var expenseMembers: [BasicUser] = []
    @State var userAmounts: UserAmountList = UserAmountList(userAmountList: [])
    
    // Set on appear
    @State var currUserId: String?
    @State var expenseId: String?
    
    @State var pendingImages: [Data] = []
    @State var savingAlert = false
    
    @State var showItemSplit: Bool = false
    @State var expenseItems: [ExpenseItem] = []
    
    var body: some View {
        ScrollView {
            ZStack {
                //Rectangle()
                //    .fill(expenseBackgroundColor)
                //    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
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
                            }
                            
                        }
                        .onTapGesture() {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        // Pull choice of groups for logged in user
                        if let groups = groupListViewModel.groups {
                            MultiSelectNav(options: groups, involvedUsers: $userAmounts).padding(.top, 15)
                        } else {
                            // Debug print
                            let _ = print(" NO GROUP OPTIONS")
                        }
                        if (!userAmounts.userAmountList.isEmpty) {
                            // Payer
                            SingleDropdown(labelName: "Paid By", groupMembers: userAmounts.userAmountsToBasicUser(), selectedItem: $expensePayerId)
                            Divider().padding(.top, 20)
                        }
                        // Involved members
                        VStack (alignment: .leading) {
                            ForEach($userAmounts.userAmountList) {$member in
                                Spacer()
                                // User input for liability amount
                                UserSplitAmount(currUserAmount: $member, groupMembers: userAmounts).padding([.top, .bottom], 20)
                            }
                            if (!userAmounts.userAmountList.isEmpty) {
                                HStack {
                                    Spacer()
                                    ButtonStyle1(buttonText: "Apply Even Split", actionFunction: {
                                        self.applyEvenSplit()
                                        // Change state variable to cause refresh
                                        expenseViewModel.expense?.totalAmount += 0
                                    })
                                    Spacer()
                                }
                            }
                        }.onTapGesture() {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        // Comments/ expense description
                        CommentBox(comment: Binding($expenseViewModel.expense)!.description)
                        
                        Button(action: {
                            showItemSplit.toggle()
                        }) {
                            Text("Item Split")
                        }
                        
                        Divider()
                        Text("Attachments")
                        AttachmentsListView(
                            existingImages: expenseViewModel.expense?.getAttachmentPaths() ?? [],
                            pendingImages: $pendingImages,
                            onRemoveExisting: { index in
                                expenseViewModel.expense?.attachmentObjectIds.remove(at: index)
                            }
                        )
                        // Divider()
                        ButtonStyle1(buttonText: "Submit", actionFunction: {
                            Task {
                                await self.createExpenseOnSubmit()
                            }
                        })
                        .padding(.top, 20)
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
                        // CAUSES CRASH
                        // userAmounts.userAmountList = []
                    } else {
                        expenseViewModel.fetchData(expenseId: expenseId!)
                    }
                }
                .onTapGesture() {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        .sheet(isPresented: $showItemSplit, content: {
            ItemSplitView(
                members: $userAmounts.userAmountList,
                expenseViewModel: expenseViewModel,
                pendingImages: $pendingImages,
                onSave: { total, users, items in
                    print(total)
                    print(users)
                    print(items)
                    userAmounts.userAmountList = users
                    expenseViewModel.expense!.totalAmount = total
                    expenseViewModel.expense!.expenseItems = items
                    showItemSplit.toggle()
                }
            )
        })
    }
    
        func attachReceipt() {
            // ToDo: Camera and camera roll launch
        }
        func applyEvenSplit() {
            // ToDO
            if let expense = expenseViewModel.expense {
                let total = expense.totalAmount
                userAmounts.applyEvenSplit(total: total)
            }
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
                    let paidByAmount = userAmounts.userAmountList.filter{$0.id == expensePayerId}[0]
                    let paidByUserAmount = UserAmount(id: paidByAmount.id, name: paidByAmount.name, profilePictureUrl: paidByAmount.profilePictureUrl, amount: expenseViewModel.expense!.totalAmount)
                    expenseViewModel.expense!.paidByDetails = [paidByUserAmount]
                    expenseViewModel.expense!.liabilityDetails = userAmounts.userAmountList
                    expenseViewModel.expense!.involvedUserIds = userAmounts.userAmountList.map{$0.id}
                    
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
            TextField("Enter title", text: $title)
                .scenePadding(.all)
                .textFieldStyle(.roundedBorder)
                .shadow(color: shadowColor, radius: 5, x: 0, y: 5)
                .font(Font.system(size: 24, design: .default))
        }.scenePadding()
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
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date).padding([.leading, .trailing], 20)
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
