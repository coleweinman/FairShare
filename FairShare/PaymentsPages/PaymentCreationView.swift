//
//  PaymentCreationView.swift
//  FairShare
//
//  Created by Melody Yin on 10/15/23.
//

import SwiftUI

struct PaymentCreationView: View {
    
    // View model to upload pament
    @ObservedObject var paymentViewModel: PaymentViewModel = PaymentViewModel()
    
    @EnvironmentObject var groupListViewModel: GroupListViewModel
    
    
    // Attributes of payment for user input
    @State var paymentAmount: String = ""
    @State var paymentDate: Date = Date()
    @State var paymentFrom: String = ""
    @State var sender: BasicUser?
    @State var paymentTo: String = ""
    @State var receiver: BasicUser?
    @State var paymentComment: String = ""
    @State var paymentTitle: String = ""
    
    @State var sendAlert = false
    @State var alertMessage = ""
    @State var allMembers: [BasicUser] = []

    var body: some View {
        ScrollView {
            VStack {
                Spacer(minLength: 50)
                // Amount
                AmountEntry(amount: $paymentAmount)
                // Date
                DateSelector(selectedDate: $paymentDate)
                // Sender
                SingleDropdown(labelName: "Payment From", groupMembers: allMembers, selectedItem: $paymentFrom)
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
        if (paymentAmount != "" && paymentFrom != "" && paymentTo != "") {
            if let amount = Decimal(string: paymentAmount) {
                // Set payment title
                for user in allMembers {
                    if (user.name == paymentFrom) {
                        sender = user
                    }
                    if (user.name == paymentTo) {
                        receiver = user
                    }
                }
                let involvedUsers = [sender?.id, receiver?.id]
                let newPayment = Payment(description: paymentComment, date: paymentDate, amount: amount, attachmentObjectIds: [], to: receiver!, from: sender!, involvedUserIds: involvedUsers as! [String])
                paymentViewModel.payment = newPayment
                let success = paymentViewModel.save()
                if (success) {
                    alertMessage = "Payment successfully created"
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
        TextField("Comments...", text: $comment, axis: .vertical).textFieldStyle(.roundedBorder).padding().lineLimit(5, reservesSpace: true).shadow(color: shadowColor, radius: 5, x: 0, y: 5)
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


