//
//  StorageImageView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/3/23.
//

import SwiftUI
import FirebaseStorage

struct StorageImageView: View {
    var path: String
    var maxWidth: CGFloat = 100
    var maxHeight: CGFloat = 100
    @State private var url: URL?
    
    func loadImage() {
        let storage = Storage.storage()
        let imageRef = storage.reference(withPath: path)
        imageRef.downloadURL { url, error in
            if let e = error {
                print(e)
            }
            self.url = url
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous).frame(width: maxWidth, height: maxHeight).foregroundColor(.white)
            if let url = self.url {
                AsyncImage(url: url) { image in
                    image.resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    ProgressView()
                }.frame(maxWidth: maxWidth, maxHeight: maxHeight).clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
            }
        }.onAppear {
            loadImage()
        }
    }
}

/*#Preview {
    StorageImageView(path: "")
}*/
