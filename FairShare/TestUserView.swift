//
//  TestUserView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/13/23.
//

import SwiftUI

struct TestUserView: View {
    @ObservedObject private var viewModel = ReceiptViewModel()
    @State var pics: [Data] = []
    
    var body: some View {
        VStack {
//            AttachmentsListView(existingImages: [], pendingImages: $pics, onSelect: { images in
//                Task {
//                    await viewModel.processReceipt(data: images[0])
//                }
//            }, onRemoveExisting: {_ in})
            Button(action: {
                
            }, label: {
                Text("Test")
            })
        }
        .onAppear() {

        }
    }
}

struct TestUserView_Previews: PreviewProvider {
    static var previews: some View {
        TestUserView()
    }
}
