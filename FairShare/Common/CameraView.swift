//
//  CameraView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/7/23.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    let onImageSelected: (Data) -> Void
    let onDismiss: () -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onImageSelected: self.onImageSelected,
            onDismiss: self.onDismiss
        )
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        private let onImageSelected: (Data) -> Void
        private let onDismiss: () -> Void
        
        init(onImageSelected: @escaping (Data) -> Void, onDismiss: @escaping () -> Void) {
            self.onImageSelected = onImageSelected
            self.onDismiss = onDismiss
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let pngData = image.pngData() {
                self.onImageSelected(pngData)
            }
            self.onDismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.onDismiss()
        }
    }
    
    
}

//#Preview {
//    CameraView()
//}
