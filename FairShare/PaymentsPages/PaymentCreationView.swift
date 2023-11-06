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
    @ObservedObject var paymentViewModel: PaymentViewModel = PaymentViewModel()
    
    @EnvironmentObject var groupListViewModel: GroupListViewModel
    
    @State var newPayment = DEFAULT_PAYMENT
    
    // Attributes of payment for user input
    //@State var paymentAmount: String = ""
    //@State var paymentDate: Date = Date()
    @State var paymentFrom: String = ""
    @State var sender: BasicUser?
    @State var paymentTo: String = ""
    @State var receiver: BasicUser?
    @State var paymentComment: String = ""
    @State var paymentTitle: String = ""
    
    @State var sendAlert = false
    @State var alertMessage = ""
    @State var allMembers: [BasicUser] = []
    
    //TODO: Write init where set newPayment to either default or fetch data

    var body: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 20)
                // Amount
                AmountEntry(amount: $newPayment.amount)
                // Date
                // DateSelector(selectedDate: $paymentDate)
                DateSelector(selectedDate: $newPayment.date)
                // Sender
                SingleDropdown(labelName: "Payment From", groupMembers: allMembers, selectedItem: $paymentFrom)
                //SingleDropdown(labelName: "Payment From", groupMembers: allMembers, selectedItem: $newPayment.from)
                // Receiver
                SingleDropdown(labelName: "Payment To", groupMembers: allMembers, selectedItem: $paymentTo)
                // Comments
                CommentBox(comment: $paymentComment)
                ButtonStyle1(buttonText:"Attach Transaction\n Confirmation", actionFunction: {self.attachImage()})
                ButtonStyle1(buttonText: "Submit", actionFunction: {self.createPaymentOnSubmit()}).alert(alertMessage, isPresented: $sendAlert) {
                    Button("OK", role: .cancel) { }
                }
            }.onAppear() {
                self.setAllMembers()
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
            if (newPayment.amount > 0){
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
                let newPayment = Payment(description: paymentComment, date: newPayment.date, amount: newPayment.amount, attachmentObjectIds: [], to: receiver!, from: sender!, involvedUserIds: involvedUsers as! [String])
                paymentViewModel.payment = newPayment
                let success = paymentViewModel.save()
                if (success) {
                    alertMessage = "Payment successfully created"
                    sendAlert = true
                    dismiss()
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
        VStack {
            Divider().padding(.top, 20)
            TextField("Comments...", text: $comment, axis: .vertical).textFieldStyle(.roundedBorder).padding().lineLimit(5, reservesSpace: true).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
        }
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
            .shadow(color: shadowColor, radius: 5, x: 0, y: 5)
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

struct PaymentCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentCreationView()
    }
}


