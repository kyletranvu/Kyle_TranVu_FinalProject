//
//  InventoryTabView.swift
//  Kyle-TranVu-FinalProject
//
//  Created by Kyle Tran-Vu on 12/5/23.
//

//: track inventory value.

import SwiftUI

//: View to manage and display inventory items
struct InventoryTabView: View {
    @Binding var inventory: [InventoryItem]
    
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var itemQuantity = ""
    @State private var isEditing = false
    @State private var selectedItem: InventoryItem?
    @State private var showingAddItem = false

    //: Calculate the total inventory value
    var totalInventoryValue: Double {
        inventory.reduce(0) { $0 + $1.totalPrice }
    }

    //: View to display inventory items
    var body: some View {
        NavigationView {
            VStack {
                Text("Total Value: $\(String(format: "%.2f", totalInventoryValue))")
                    .padding()
                    .font(.headline)
                InventoryView(inventory: $inventory, isEditing: $isEditing, selectedItem: $selectedItem)
                    .navigationBarTitle("Current Inventory")
                    .navigationBarItems(trailing:
                        HStack {
                            //: Button to add inventory items
                            Button("Add Item") {
                                showingAddItem = true
                            }
                            //: Button to edit inventory items
                            Button(action: {
                                isEditing.toggle()
                                selectedItem = nil
                            }) {
                                Text(isEditing ? "Done" : "Edit")
                            }
                        })
                //: Button to clear inventory
                HStack {
                    Spacer()
                        Button("Clear Inventory") {
                            clearInventory()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            }
            //: Sheet to add new item to inventory
            .sheet(isPresented: $showingAddItem) {
                AddInventoryItemView(inventory: $inventory, showingAddItem: $showingAddItem, itemName: $itemName, itemPrice: $itemPrice, itemQuantity: $itemQuantity, isEditing: $isEditing, selectedItem: $selectedItem)
            }
        }
    }

    //: Function to clear items from inventory
    private func clearInventory() {
        inventory.removeAll()
    }
}

//: Structure that represents a single item
struct InventoryItem: Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    var quantity: Int
    var isIncoming: Bool
    var image: UIImage?

    //: Calculate the total price of each item based on quantity
    var totalPrice: Double {
        price * Double(quantity)
    }
}

//: Display the list of inventory items
struct InventoryView: View {
    @Binding var inventory: [InventoryItem]
    @Binding var isEditing: Bool
    @Binding var selectedItem: InventoryItem?

    var body: some View {
        List {
            ForEach(inventory) { item in
                //: Display image of item in inventory if applicable
                HStack {
                    if let image = item.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    //: Display item name, price, quantity
                    Text("\(item.name): $\(item.price, specifier: "%.2f") (\(item.quantity) units)")
                    Spacer()
                    //: Show delete item button when editing
                    if isEditing {
                        //: Button to delete items from inventory
                        Button(action: {
                            if let index = inventory.firstIndex(where: { $0.id == item.id }) {
                                inventory.remove(at: index)
                            }
                        }) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
    }
}

//: View to add/edit items in the inventory
struct AddInventoryItemView: View {
    @Binding var inventory: [InventoryItem]
    @Binding var showingAddItem: Bool
    @Binding var itemName: String
    @Binding var itemPrice: String
    @Binding var itemQuantity: String
    @Binding var isEditing: Bool
    @Binding var selectedItem: InventoryItem?
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Enter item name", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Enter item price", text: $itemPrice)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Enter quantity", text: $itemQuantity)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                //: Display selected image if applicable
                if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                
                //: Button to select an image
                HStack {
                    Spacer()
                    Button("Select Image") {
                        showingImagePicker = true
                    }
                    Spacer()
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                }

                //: Button to add/save item
                HStack {
                    Spacer()
                    Button(isEditing ? "Save Changes" : "Add Item") {
                        addOrEditItem()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle("Add Item To Inventory", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                showingAddItem = false
            })
        }
    }

    //: Function to load selected image
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        if isEditing, let selectedItem = selectedItem, let index = inventory.firstIndex(where: { $0.id == selectedItem.id }) {
            inventory[index].image = inputImage
        }
    }

    //: Function to add/edit items in the inventory
    private func addOrEditItem() {
        if let price = Double(itemPrice), let quantity = Int(itemQuantity), !itemName.isEmpty {
            let newItem = InventoryItem(name: itemName, price: price, quantity: quantity, isIncoming: true, image: inputImage)

            if isEditing, let selectedItem = selectedItem, let index = inventory.firstIndex(where: { $0.id == selectedItem.id }) {
                inventory[index] = newItem
            } else {
                inventory.append(newItem)
            }

            resetFields()
            showingAddItem = false
        }
    }
    
    //: Function to reset all input fields
    private func resetFields() {
        itemName = ""
        itemPrice = ""
        itemQuantity = ""
        isEditing = false
        selectedItem = nil
        inputImage = nil
    }
}

//: Structure to pick an image using UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    //: Function that creates an instance of UIImagePickerController
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    //: Function to update the view controller. Not used because the controller is not updated
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    //: Function to manage communication between the view and controller
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        //: Function called when image is selected
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}



