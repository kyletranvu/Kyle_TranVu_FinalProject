//
//  ContentView.swift
//  Kyle-TranVu-FinalProject
//
//  Created by Kyle Tran-Vu on 12/4/23.
//

//: Empathize: Who is the user - Hunter Fox
//: Define: how our app is going to help/assist/support
//: Ideate: Scenarios or Storyboard + Wireframe - My roommate Hunter has a shoe selling business, so this app will help him track his inventory and expenses when buying or selling shoes
//: Prototype: Develop the app
//: Evaluate: Make sure that design heuristics apply

import SwiftUI

struct ContentView: View {
    @State private var inventory: [InventoryItem] = []
    @State private var transactions: [InventoryTransaction] = []

    var body: some View {
        TabView {
            TransactionsTabView(inventory: $inventory).tabItem {
                Image(systemName: "dollarsign.circle")
                Text("Transactions")
            }

            InventoryTabView(inventory: $inventory).tabItem {
                Image(systemName: "archivebox")
                Text("Inventory")
            }
            
            SettingsTabView(inventory: $inventory, transactions: $transactions).tabItem{
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

#Preview {
    ContentView()
}
