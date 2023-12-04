//
//  ViewPaymentPage.swift
//  FairShare
//
//  Created by Melody Yin on 11/27/23.
//

import SwiftUI
import NukeUI

struct ViewPaymentPage: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var paymentViewModel: PaymentViewModel = PaymentViewModel()
    
    @EnvironmentObject var viewModel: UserViewModel
    
    @State var showConfirmationDialogue = false
    
    var paymentId: String
    
    var canEdit: Bool
    
    var body: some View {
        VStack {
            if let currPayment = paymentViewModel.payment {
                VStack (alignment: .center) {
                    Divider()
                    let stringAmount = "$\(currPayment.amount)"
                    // TODO: FIGURE OUT TITLE
                    if let currUser = viewModel.user {
                        Text(stringAmount).navigationTitle("\(currPayment.setPaymentTitle(currUser: BasicUser(id: currUser.id!, name: currUser.name)))").font(.system(size: 64, design: .rounded))
                    } else {
                        Text(stringAmount).font(.system(size: 64, design: .rounded))
                    }
                    if (currPayment.description != "") {
                        Text("\"\(currPayment.description)\"").font(.system(size: 18, design: .rounded))
                    }
                    Divider()
                }
                HStack {
                    VStack (alignment: .leading) {
                        Text("Payment To").font(.system(size: 18,  weight: .semibold, design: .rounded))
                        HStack (alignment: .top) {
                            PFP(image: currPayment.to.profilePictureUrl, size: 64)
                            Spacer()
                            Text(currPayment.to.name).font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        
                        Divider()
                        Text("Payment From").font(.system(size: 18,  weight: .semibold, design: .rounded))
                        HStack (alignment: .top) {
                            PFP(image: currPayment.from.profilePictureUrl, size: 64)
                            Spacer()
                            Text(currPayment.from.name).font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        Divider()
                        
                        HStack {
                            Text("Date of Payment").font(.system(size: 18,  weight: .semibold, design: .rounded))
                            let dateFormatter = DateFormatter()
                            let _ = dateFormatter.dateStyle = .long
                            Spacer()
                            Text(dateFormatter.string(from: currPayment.date)).font(.system(size: 18, design: .rounded))
                        }.padding(.top)
                        
                    }
                    Spacer()
                }
                Spacer()
            }
            
        }.toolbar {
            if (canEdit) {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        // Action
                        PaymentCreationView(paymentId: paymentId)
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                   Button {
                       // Open confirmation of delete with ok and cancel
                       showConfirmationDialogue.toggle()
                    } label: {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }
            }
        }.confirmationDialog("Confirm deletion", isPresented: $showConfirmationDialogue) {
            Button("Confirm") { // Call delete
                paymentViewModel.deleteData(paymentId: paymentId)
                self.presentationMode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Delete payment?")
        }.onAppear() {
            paymentViewModel.fetchData(paymentId: paymentId)
        }.padding()
    }
}
