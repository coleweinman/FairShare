//
//  SettingsPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI
import FirebaseStorage

private let storage = Storage.storage()
private let storageRef = storage.reference()

struct SettingsPageView: View {
    @EnvironmentObject var viewModel: UserViewModel

    @State private var showActionSheet = false
    @State private var selectedFrequency = 0
    let frequencies = ["Daily", "Every Other Day", "Weekly"]
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            ZStack{
                if let profileUrl = viewModel.user?.profilePictureUrl {
                    AsyncImage(url: profileUrl) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill) 
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                Button(action: {
                    isImagePickerPresented.toggle()
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                }
                .offset(x: 25, y: 10)
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $selectedImage, onImageSelected: { uiImage in
                    // Upload the image to Firebase Storage
                    if let uiImage = uiImage {
                        let picRef = storageRef.child("profilePictures/\(viewModel.user!.id!).jpg")
                        _ = picRef.putData(uiImage.jpegData(compressionQuality: 0.5)!, metadata: nil) { metadata, error in
                            guard metadata != nil else {
                                print("Error uploading image: \(error?.localizedDescription ?? "")")
                                return
                            }
                            picRef.downloadURL { (url, error) in
                                guard let downloadURL = url else {
                                    print("Error getting download URL: \(error?.localizedDescription ?? "")")
                                    return
                                }
                                viewModel.updateField(userId: viewModel.user!.id!, field: "profilePictureUrl", value: downloadURL.absoluteString)
                            }
                        }
                    }
                }
            )}
            }
        }
        Text(viewModel.user!.name)
            List() {
                Section(header: Text("Notifications")) {
                    Toggle("Payment Reminders", isOn: Binding($viewModel.user)!.paymentRemindersEnabled)
                        .onChange(of: viewModel.user!.paymentRemindersEnabled) { newValue in
                            viewModel.updateField(userId: viewModel.user!.id!, field: "paymentRemindersEnabled", value: newValue)
                        }
                    if viewModel.user?.paymentRemindersEnabled ?? false {
                        Picker("Payment Reminder Frequency", selection: Binding($viewModel.user)!.paymentRemindersFrequency) {
                            Text("Daily").tag("Daily")
                            Text("Every Other Day").tag("Every Other Day")
                            Text("Weekly").tag("Weekly")
                        }
                        .pickerStyle(.navigationLink)
                    }
                    Toggle("New Expense Notifcations", isOn: Binding($viewModel.user)!.newExpenseNotificationEnabled)
                    .onChange(of: viewModel.user!.newExpenseNotificationEnabled) { newValue in
                        viewModel.updateField(userId: viewModel.user!.id!, field: "newExpenseNotificationEnabled", value: newValue)
                    }
                }
                Section(header: Text("Account Info")) {
                    Text("Name: \(viewModel.user!.name)")
                    Text("Email: \(viewModel.user!.email)")
                }
                LogoutButton()
            }
            .navigationTitle("Settings")
        }
}

struct LogoutButton: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                print(authViewModel.signOut())
            }) {
                Text("Logout")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            Spacer()
        }
    }
}

struct SettingsPageView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPageView()
    }
}

// Profile picture selection
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: ((UIImage?) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImageSelected?(uiImage)
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
