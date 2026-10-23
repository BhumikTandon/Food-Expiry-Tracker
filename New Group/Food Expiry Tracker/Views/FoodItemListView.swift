//
//  FoodItemListView.swift
//  Food Expiry Tracker
//
//  Created by Bhumik Tandon on 3/29/25.
//

import SwiftUI

struct FoodItemListView: View {
    @StateObject private var foodManager = FoodItemManager()
    
    @State private var newName = ""
    @State private var newDate = Date()  // Use current date for example
    
    var body: some View {
        VStack {
            Text("My Food Items").font(.largeTitle).padding(.top)
            
            List {
                ForEach(foodManager.foodItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "Unnamed").font(.headline)
                            if let date = item.expiryDate {
                                Text("Expires: \(date.formatted(date: .numeric, time: .omitted))")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                        Button("Delete") {
                            foodManager.deleteItem(item)
                        }
                    }
                }
            }
            
            // Form to add an item
            VStack {
                TextField("Food Name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker("Expiry Date", selection: $newDate, displayedComponents: .date)
                
                Button("Add Food") {
                    foodManager.addItem(name: newName, expiryDate: newDate)
                    newName = ""
                    newDate = Date()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
            .padding(.horizontal)
        }
        .onAppear {
            foodManager.fetchItems()
        }
        .padding(.bottom)
    }
}
