//
//  AttachmentsListView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/2/23.
//

import SwiftUI
import PhotosUI

struct ImagePopoverData: Identifiable {
    var id: String { selectedImagePath ?? selectedImageData?.description ?? "" }
    var selectedImagePath: String?
    var selectedImageData: Data?
}

struct AttachmentsListView: View {
    var existingImages: [String]
    @State var pendingImages: [Data]
    @State var selectedItems: [PhotosPickerItem] = []
    @State var viewImage: Bool = false
    @State var selectedImagePath: String?
    @State var selectedImageData: Data?
    @State var imagePopoverData: ImagePopoverData?
    
    init(existingImages: [String], pendingImages: [Data], onSelect: @escaping ([Data]) -> Void) {
        self.existingImages = existingImages
        self.pendingImages = pendingImages
        self.onSelect = onSelect
        print(existingImages)
    }
    
    var onSelect: (([Data]) -> Void)
    
    func loadImages(photos: [PhotosPickerItem]) async throws -> [Data] {
        var images: [Data] = []
        try await withThrowingTaskGroup(of: (Data?).self, body: { group in
            for photo in photos {
                group.addTask {
                    async let data = photo.loadTransferable(type: Data.self)
                    return try await data
                }
            }
            for try await data in group {
                if let image = data {
                    images += [image]
                }
            }
        })
        return images
    }
    
    var body: some View {
        ScrollView {
            ForEach(existingImages, id: \.self) { path in
                StorageImageView(path: path)
                    .onTapGesture {
                        imagePopoverData = ImagePopoverData(selectedImagePath: path)
                    }
            }
            ForEach(pendingImages, id: \.self) { image in
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        imagePopoverData = ImagePopoverData(selectedImageData: image)
                    }
            }
            PhotosPicker(selection: $selectedItems,
                         matching: .images,
                         photoLibrary: .shared()) {
            Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
             .onChange(of: selectedItems, perform: { photos in
                 Task {
                     do {
                         let images = try await loadImages(photos: photos)
                         self.pendingImages = images
                         onSelect(images)
                     }
                     
                 }
             })
        }
        .popover(item: $imagePopoverData, attachmentAnchor: .point(.center)) { data in
            if let path = data.selectedImagePath {
                StorageImageView(path: path, maxWidth: UIScreen.main.bounds.width - 20, maxHeight: UIScreen.main.bounds.height - 50)
                    .presentationCompactAdaptation(.popover)
            } else {
                Image(uiImage: UIImage(data: data.selectedImageData!)!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width - 20, maxHeight: UIScreen.main.bounds.height - 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
}

#Preview {
    AttachmentsListView(existingImages: [], pendingImages: [], onSelect: {_ in })
}
