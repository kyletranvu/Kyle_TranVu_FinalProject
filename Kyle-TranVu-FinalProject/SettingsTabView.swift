//
//  SettingsTabView.swift
//  Kyle-TranVu-FinalProject
//
//  Created by Kyle Tran-Vu on 12/5/23.
//

import SwiftUI

//: View for managing application settings
struct SettingsTabView: View {
    @Binding var inventory: [InventoryItem]
    @Binding var transactions: [InventoryTransaction]
    
    @State private var isDarkMode: Bool = false
    @State private var notificationsEnabled: Bool = false
    
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    
    @AppStorage("isDarkMode") var storedIsDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                //: Profile Section
                GroupBox(label: Text("Profile").bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            profileImage.map {
                                Image(uiImage: $0)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                            Button("Select Image") {
                                showingImagePicker = true
                            }
                        }
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(image: self.$profileImage)
                        }
                        HStack {
                            Text("Name:")
                            Spacer()
                            TextField("Enter your name", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                        HStack {
                            Text("Email:")
                            Spacer()
                            TextField("Enter your email", text: $userEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding()
                }
                .groupBoxStyle(DefaultGroupBoxStyle())
                
                //: Section for appearance settings (dark mode)
                Text("Appearance").font(.headline)
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }
                .onChange(of: isDarkMode) { newValue in
                    storedIsDarkMode = newValue
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                }
                
                //: Section for notifications
                Text("Notifications").font(.headline)
                Toggle(isOn: $notificationsEnabled) {
                    Text("Enable Notifications")
                }

                Spacer()

                //: Button to reset all settings
                HStack {
                    Spacer()
                        Button("Reset Settings") {
                            resetAllSettings()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                    }
                }
            .padding()
            .navigationBarTitle("Settings")
        }
    }

    //: Function to clear all settings
    private func resetAllSettings() {
        isDarkMode = false
        storedIsDarkMode = false
        notificationsEnabled = false
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
    }
    
    //: Function to save profile
    func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        print("Profile saved")
    }
}
