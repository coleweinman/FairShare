//
//  PaymentCreationView.swift
//  FairShare
//
//  Created by Melody Yin on 10/15/23.
//

import SwiftUI

let DEFAULT_USER = BasicUser(id: "", name: "")

let DEFAULT_PAYMENT = Payment(description: "", date: Date(), amount: 0.0, attachmentObjectIds: [], to: DEFAULT_USER, from: DEFAULT_USER, involvedUserIds: [])

struct PaymentCreationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // View model to upload pament
    @StateObject var paymentViewModel: PaymentViewModel = PaymentViewModel()
    
    // View Model to access current user logged in
    @EnvironmentObject var userViewModel: UserViewModel
    
    @EnvironmentObject var groupListViewModel: GroupListViewModel
    
    @State var paymentFrom: String = ""
    @State var sender: BasicUser?
    @State var paymentTo: String = ""
    @State var receiver: BasicUser?
    
    // Alert attributes for submission
    @State var sendAlert = false
    @State var alertMessage = ""
    
    // Set on appear
    @State var allMembers: [BasicUser] = []
    var paymentId: String?
    @State var currUserId: String?

    var body: some View {
        ScrollView {
            VStack {
                if (paymentViewModel.payment != nil) {
                    Spacer(minLength: 20)
                    VStack {
                        // Amount
                        AmountEntry(amount: Binding($paymentViewModel.payment)!.amount)
                        // Date
                        DateSelector(selectedDate: Binding($paymentViewModel.payment)!.date)
                    }.onAppear() {
                        if let currPayment = paymentViewModel.payment {
                            if (paymentFrom == "") {
                                paymentFrom = currPayment.from.id
                            }
                            if (paymentTo == "") {
                                paymentTo = currPayment.to.id
                            }
                        }
                    }
                    // Sender
                    SingleDropdown(labelName: "Payment From", groupMembers: allMembers, selectedItem: $paymentFrom)
                    // Receiver
                    SingleDropdown(labelName: "Payment To", groupMembers: allMembers, selectedItem: $paymentTo)
                    // Comments
                    CommentBox(comment: Binding($paymentViewModel.payment)!.description)
                    //ButtonStyle1(buttonText:"Attach Transaction\n Confirmation", actionFunction: {self.attachImage()})
                    ButtonStyle1(buttonText: "Submit", actionFunction: {self.createPaymentOnSubmit()}).alert(alertMessage, isPresented: $sendAlert) {
                        Button("OK", role: .cancel) {
                            if (alertMessage == "Payment successful") {
                                dismiss()
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }.onAppear() {
                self.setAllMembers()
                currUserId = userViewModel.user!.id
                if (paymentId == nil) {
                    // No paymentID given
                    if (paymentViewModel.payment == nil) {
                        paymentViewModel.payment = DEFAULT_PAYMENT
                    }
                } else {
                    print("fetching")
                    paymentViewModel.fetchData(paymentId: paymentId!)
                }
            }
        }
    }
    
    func setAllMembers() {
        if let groups = groupListViewModel.groups {
            for group in groups {
                for user in group.members {
                    if (!allMembers.contains(user)) {
                        allMembers.append(user)
                    }
                }
            }
        }
    }
    
    func attachImage() {
        // ToDo: Camera and camera roll launch
    }
    
    // Respond to submit button press, use state vars to create and store payment
    func createPaymentOnSubmit() {
        if (paymentFrom != "" && paymentTo != "") {
            if (paymentViewModel.payment!.amount > 0){
                // Set payment title
                for user in allMembers {
                    if (user.id == paymentFrom) {
                        sender = user
                    }
                    if (user.id == paymentTo) {
                        receiver = user
                    }
                }
                let involvedUsers = [sender?.id, receiver?.id]
                paymentViewModel.payment?.to = receiver!
                paymentViewModel.payment?.from = sender!
                paymentViewModel.payment?.involvedUserIds = involvedUsers as! [String]
                let success = paymentViewModel.save()
                if (success) {
                    alertMessage = "Payment successful"
                    sendAlert = true
                } else {
                    alertMessage = "Failed to create payment"
                    sendAlert = true
                }
            } else {
                alertMessage = "Invalid amount"
                sendAlert = true
            }
        } else {
            alertMessage = "Please fill out all information"
            sendAlert = true
        }
    }
}

// Text field for comment entry
struct CommentBox: View {
    @Binding var comment: String
    
    var body: some View {
        VStack (alignment: .leading){
            Divider().padding(.top, 20)
            //Text("Expense Comments").scenePadding(.all).padding(.bottom, -15)
            TextField(" Comments...", text: $comment, axis: .vertical)
                .font(Font.system(size: 18, design: .default))
                /*.textFieldStyle(.roundedBorder)
                .shadow(color: shadowColor, radius: 2, x: 0, y: 2)*/
                .background(
                    RoundedRectangle(cornerRadius: 8).foregroundColor(.white)
                        .shadow(color: shadowColor, radius: 2, x: 0, y: 2).padding(-10)
                )
                .lineLimit(5, reservesSpace: true)
                .padding()
        }.onTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }.scenePadding(.all)
    }
}

// Generic button
struct ButtonStyle1: View {
    
    let buttonText: String
    var actionFunction: () -> Void
    var body: some View {
        Button(buttonText) {
            // What to do on button press
            actionFunction()
        }.buttonStyle(.bordered).foregroundColor(.white).background(.mint).cornerRadius(10).font(Font.system(size: 16, design: .default))
            .shadow(color: shadowColor, radius: 2, x: 0, y: 2)
    }
}

// TODO
struct SearchBar: View {
    @State private var searchTerm = ""
    
    var body: some View {
        NavigationStack {
            Text("Test")
        }.searchable(text: $searchTerm, prompt: "Search")
    }
}

/*struct PaymentCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCreationView()
    }
}*/


