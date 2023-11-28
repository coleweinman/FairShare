//
//  ItemSplitView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/14/23.
//

import SwiftUI

func getSplitDict(users: [UserAmount]) -> [String : Decimal] {
    var dict: [String : Decimal] = [:]
    for user in users {
        dict[user.id] = 0
    }
    return dict
}

struct ItemSplitView: View {
    @State var listSelectionPresented: Bool = false
    @Binding var members: [UserAmount]
    @StateObject var viewModel: ItemSplitViewModel = ItemSplitViewModel(expenseItems: [])
    @State var attachmentsOpen: Bool = false
    var expenseViewModel: ExpenseViewModel
    @Binding var pendingImages: [Data]
    @EnvironmentObject var userViewModel: UserViewModel
    
    var onSave: (Decimal, [UserAmount], [ExpenseItem]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($viewModel.expenseItems) { $item in
                    ItemElement(members: $members, viewModel: item)
                        .swipeActions {
                            Button (
                                action: {
                                    viewModel.expenseItems.removeAll(where: { vm in vm.id == item.id })
                                },
                                label: {
                                    Label("Delete", systemImage: "trash")
                                        .tint(.red)
                                }
                            )
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { d in
                            d[.leading]
                        }
                }
                Button(
                    action: {
                        viewModel.expenseItems.append(ExpenseItemViewModel(item: ExpenseItem(name: "", amount: 0, split: getSplitDict(users: members))))
                    },
                    label: {
                        Label("Add Item Manually", systemImage: "plus")
                    }
                )
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }
                Button(
                    action: {
                        listSelectionPresented.toggle()
                    },
                    label: {
                        Label("Add Items from List", systemImage: "list.bullet")
                    }
                )
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }
                Button(
                    action: {
                        attachmentsOpen.toggle()
                    },
                    label: {
                        Label("Add Items from Receipt", systemImage: "camera")
                    }
                )
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .primaryAction, content: {
                    Button("Save") {
                        let result = viewModel.getNewUsers(users: members)
                        self.onSave(result.0, result.1, viewModel.expenseItems.map { vm in vm.item })
                    }
                })
                ToolbarItem(placement: .cancellationAction, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                })
            }
            .navigationTitle("Split by Items")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDragIndicator(.visible)
            .sheet(isPresented: $listSelectionPresented) {
                ListSelectionPage { list in
                    for item in list.items {
                        viewModel.expenseItems.append(ExpenseItemViewModel(item: ExpenseItem(name: item.name, amount: 0, split: getSplitDict(users: members))))
                    }
                    listSelectionPresented = false
                }
            }
            .sheet(isPresented: $attachmentsOpen) {
                NavigationStack {
                    AttachmentsListView(
                        existingImages: expenseViewModel.expense?.getAttachmentPaths() ?? [],
                        pendingImages: $pendingImages,
                        onRemoveExisting: { index in
                            expenseViewModel.expense?.attachmentObjectIds.remove(at: index)
                        },
                        onTapPending: { image in
                            attachmentsOpen = false
                            Task {
                                await viewModel.processPendingImage(uid: userViewModel.user!.id!, data: image, users: members)
                            }
                            
                        },
                        onTapExisting: { path in
                            attachmentsOpen = false
                            Task {
                                await viewModel.processExistingImage(path: path, users: members)
                            }
                        }
                    )
                    .navigationTitle("Select Attachment")
                    .navigationBarTitleDisplayMode(.inline)
                    .presentationDragIndicator(.visible)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction, content: {
                            Button("Cancel") {
                                attachmentsOpen = false
                            }
                        })
                    }
                }
            }
            .overlay() {
                LoadingOverlayView(enabled: $viewModel.loadingReceipt)
            }
        }
        .onAppear {
            viewModel.expenseItems = (expenseViewModel.expense?.expenseItems ?? []).map { ei in ExpenseItemViewModel(item: ei) }
        }
    }
}

struct ItemElement: View {
    @Binding var members: [UserAmount]
    @StateObject var viewModel: ExpenseItemViewModel
    @State var amountText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField(
                    text: $viewModel.item.name,
                    label: {
                        Text("Name")
                    }
                )
                TextField(
                    text: $amountText,
                    label: {
                        Text("Amount")
                    }
                ).frame(width: 100)
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            
            ForEach($members) { member in
                SplitToggle(user: member, split: $viewModel.item.split)
            }
        }
        .onChange(of: amountText) { val in
            print("on change")
            viewModel.item.amount = Decimal(string: val) ?? viewModel.item.amount
        }
        .textFieldStyle(.roundedBorder)
        .onAppear {
            amountText = viewModel.item.amount.formatted()
        }
    }
}

struct SplitToggle: View {
    @Binding var user: UserAmount
    @Binding var split: [String : Decimal]
    
    
    
    var body: some View {
        let toggleBinding = Binding<Bool>(
            get: { split.contains(where: {k, v in user.id == k}) },
            set: { value in
                if value {
                    split[user.id] = 0
                } else {
                    split.removeValue(forKey: user.id)
                }
            }
        )
        return Toggle(isOn: toggleBinding, label: {
            HStack {
                PFP(image: user.profilePictureUrl)
                Text(user.name)
            }
            
        })
                
    }
}

//#Preview {
//    ItemSplitView()
//}
