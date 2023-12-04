//
//  AttachmentsListView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/2/23.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct ImagePopoverData: Identifiable {
    var id: String { selectedImagePath ?? selectedImageData?.description ?? "" }
    var index: Int
    var selectedImagePath: String?
    var selectedImageData: Data?
}

struct AttachmentsListView: View {
    var existingImages: [String]
    @Binding var pendingImages: [Data]
    @State var selectedItems: [PhotosPickerItem] = []
    @State var viewImage: Bool = false
    @State var selectedImagePath: String?
    @State var selectedImageData: Data?
    @State var imagePopoverData: ImagePopoverData?
    @State var cameraOpen: Bool = false
    @State var errorAlert: Bool = false
    @State var errorAlertMessage: String = ""
    
    var onRemoveExisting: ((Int) -> Void)
    
    var onTapPending: ((Data) -> Void)?
    var onTapExisting: ((String) -> Void)?
    
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
                        if let onTap = onTapExisting {
                            onTap(path)
                        } else {
                            imagePopoverData = ImagePopoverData(index: existingImages.firstIndex(of: path)!, selectedImagePath: path)
                        }
                    }
            }
            ForEach(pendingImages.indices, id: \.self) { index in
                let image = pendingImages[index]
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(maxWidth: UIScreen.main.bounds.width - 10, maxHeight: 400)
                    .onTapGesture {
                        if let onTap = onTapPending {
                            onTap(image)
                        } else {
                            imagePopoverData = ImagePopoverData(index: index, selectedImageData: image)
                        }
                    }
            }
            PhotosPicker(selection: $selectedItems,
                         matching: .images,
                         photoLibrary: .shared()) {
                Label("Add from Photos", systemImage: "photo")
            }
             .onChange(of: selectedItems, perform: { photos in
                 if photos.count > 0 {
                     Task {
                         do {
                             let images = try await loadImages(photos: photos)
                             self.pendingImages.append(contentsOf: images)
                             selectedItems.removeAll()
                         }
                     }
                 }
             }).padding()
            Button(action: {
                self.openCamera()
            }, label: {
                Label("Add from Camera", systemImage: "camera")
            }).padding()
        }.onTapGesture() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .sheet(item: $imagePopoverData) { data in
            Button("Remove", systemImage: "trash", action: {
                if data.selectedImageData != nil {
                    self.pendingImages.remove(at: data.index)
                } else {
                    print(data.index)
                    self.onRemoveExisting(data.index)
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
        .fullScreenCover(isPresented: $cameraOpen) {
            CameraView(
                onImageSelected: { image in
                    pendingImages.append(image)
                }, 
                onDismiss: {
                    self.cameraOpen = false
                }
            ).ignoresSafeArea(.all)
        }
        .alert(isPresented: $errorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorAlertMessage)
            )
        }
    }
    
    func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if authorized {
                    self.cameraOpen = true
                } else {
                    errorAlert = true
                    errorAlertMessage = "Please grant camera permission"
                }
            }
        } else {
            self.cameraOpen = true
        }
    }
}
