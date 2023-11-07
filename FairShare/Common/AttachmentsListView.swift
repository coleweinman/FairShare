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
    
    init(existingImages: [String], pendingImages: [Data], onSelect: @escaping ([Data]) -> Void, onRemoveExisting: @escaping (String) -> Void) {
        self.existingImages = existingImages
        self.pendingImages = pendingImages
        self.onSelect = onSelect
        self.onRemoveExisting = onRemoveExisting
        print(existingImages)
    }
    
    var onSelect: (([Data]) -> Void)
    var onRemoveExisting: ((String) -> Void)
    
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
                StorageImageView(path: path, maxWidth: UIScreen.main.bounds.width - 10, maxHeight: 400)
                    .onTapGesture {
                        imagePopoverData = ImagePopoverData(selectedImagePath: path)
                    }
            }
            ForEach(pendingImages, id: \.self) { image in
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: UIScreen.main.bounds.width - 10, maxHeight: 400)
                    .onTapGesture {
                        imagePopoverData = ImagePopoverData(selectedImageData: image)
                    }
            }
            PhotosPicker(selection: $selectedItems,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label("Add", systemImage: "plus")
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
        .sheet(item: $imagePopoverData) { data in
            Button("Remove", systemImage: "trash", action: {
                if data.selectedImageData != nil {
                    self.pendingImages.removeAll(where: {pi in pi == data.selectedImageData})
                    self.onSelect(self.pendingImages)
                } else {
                    self.onRemoveExisting(data.selectedImagePath!)
                }
                imagePopoverData = nil
            }).padding()
            GeometryReader { geo in
                if let path = data.selectedImagePath {
                    StorageImageView(path: path, maxWidth: geo.size.width, maxHeight: geo.size.height)
                } else {
                    Image(uiImage: UIImage(data: data.selectedImageData!)!)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
        }
    }
}

#Preview {
    AttachmentsListView(existingImages: [], pendingImages: [], onSelect: {_ in }, onRemoveExisting: {_ in })
}
