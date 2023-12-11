//
//  TransactionsTabView.swift
//  Kyle-TranVu-FinalProject
//
//  Created by Kyle Tran-Vu on 12/5/23.
//

//: show Transactions. track the cost and report balance of what is being purchased/sold

import SwiftUI

//: View for managing transactions
struct TransactionsTabView: View {
    @Binding var inventory: [InventoryItem] //: Bind to inventory array
    
    @State private var transactions: [InventoryTransaction] = [] //: Track all transactions
    @State private var balance: Double = 0.0 //: Current balance
    @State private var profitOrLoss: Double = 0.0 //: Calculates total profit/loss
    @State private var showingAddTransaction = false //: Control display of add transaction
    @State private var newItemName: String = "" //: Hold the name of the new item
    @State private var newAmount: String = "" //: Holds the amount for the new transaction
    @State private var isNewItemIncoming: Bool = true //: Determine if the new transction is an incoming/outgoing item

    var body: some View {
        NavigationView {
            VStack {
                //: Display the current balance
                Text("Balance: $\(profitOrLoss, specifier: "%.2f")")
                    .font(.headline)
                    .padding()
                //: List of transactions
                List {
                    ForEach(transactions) { transaction in
                        HStack {
                            Text(transaction.itemName)
                            Spacer()
                            Text(transaction.isIncoming ? "Purchased" : "Sold")
                            Spacer()
                            Text(formatAmount(transaction.amount))
                        }
                    }
                    .onDelete(perform: deleteTransaction)
                }
                //: Button to clear transaction history
                HStack {
                    Spacer()
                    Button("Clear Transaction History") {
                        clearTransactionHistory()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                }
            }
            .navigationBarTitle("Transactions")
            //: Toolbar item to add new transaction
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Transaction") {
                        showingAddTransaction = true
                    }
                }
            }
            //: Sheet for adding new transaction
            .sheet(isPresented: $showingAddTransaction) {
                NavigationView {
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer().frame(height: 20)
                        //: Inputs for new transaction details
                        TextField("Item Name", text: $newItemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Amount", text: $newAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Toggle(isOn: $isNewItemIncoming) {
                            Text("Is Incoming")
                        }
                        //: Button to add new transactions
                        HStack {
                            Spacer()
                                Button("Add") {
                                    addNewTransaction()
                                }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        Spacer()
                    }
                    .padding()
                    .navigationBarTitle("New Transaction", displayMode: .inline)
                    .navigationBarItems(leading: Button("Cancel") {
                        showingAddTransaction = false
                        resetFields()
                    })
                }
            }
            .onAppear {
                //: Calculate balance and profit/losses
                calculateBalance()
                calculateProfitOrLoss()
            }
        }
    }
    
    //: Function to format the transaction amount
    private func formatAmount(_ amount: Double) -> String {
            let formattedAmount = String(format: "%.2f", abs(amount))
            return amount < 0 ? "-$\(formattedAmount)" : "$\(formattedAmount)"
        }
    
    //: Function to clear transaction history
    private func clearTransactionHistory() {
            transactions.removeAll()
        }

    //: Function to calculate current balance from all transactions in the list
    private func calculateBalance() {
        balance = transactions.reduce(0) { $0 + $1.amount }
                calculateProfitOrLoss()
    }

    //: Function to calculate total profit/loss
    private func calculateProfitOrLoss() {
        profitOrLoss = balance
    }

    //: Function to add new transaction to the list
    private func addNewTransaction() {
        if let amountDouble = Double(newAmount), !newItemName.isEmpty {
            // Negate the amount for incoming transactions
            let finalAmount = isNewItemIncoming ? -amountDouble : amountDouble
            let newTransaction = InventoryTransaction(itemName: newItemName, amount: finalAmount, isIncoming: isNewItemIncoming)
            transactions.append(newTransaction)
            calculateBalance()
            resetFields()
            showingAddTransaction = false
        }
    }

    //: Function to remove a transaction from the list
    private func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        calculateBalance()
    }

    //: Function to reset all data fields
    private func resetFields() {
        newItemName = ""
        newAmount = ""
        isNewItemIncoming = true
    }
}

//: Structure that represents a single transaction
struct InventoryTransaction: Identifiable {
    let id = UUID()
    var itemName: String
    var amount: Double
    var isIncoming: Bool
}

