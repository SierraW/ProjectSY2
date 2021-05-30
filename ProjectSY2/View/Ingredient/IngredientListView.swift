//
//  IngredientListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct IngredientListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var ingredientData: IngredientData
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Ingredient.name, ascending: true)],
                  animation: .default)
    var ingredients: FetchedResults<Ingredient>
    var isDeleteDisabled = false
    var selected: ((Ingredient) -> Void)?
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Ingredient")
                        .font(.title)
                    Spacer()
                    Button("Add") {
                        ingredientData.set(nil)
                    }
                }
                listView
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $ingredientData.isShowingIngredientDetailView, content: {
            IngredientAdditionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(ingredientData)
        })
    }
    
    @ViewBuilder
    var listView: some View {
        if ingredients.isEmpty {
            HStack {
                Text("Empty")
                Spacer()
            }
        } else {
            List {
                ForEach(ingredients) { item in
                    Button(item.name ?? "Error item") {
                        if selected == nil {
                            ingredientData.set(item)
                        } else {
                            selected!(item)
                        }
                    }
                }
                .onDelete(perform: removeIngredients)
                .deleteDisabled(isDeleteDisabled)
            }
        }
    }
    
    func removeIngredients(_ indexSet: IndexSet) {
        for index in indexSet {
            let ingredient = ingredients[index]
            viewContext.delete(ingredient)
        }
        do {
            try viewContext.save()
        } catch {
            
        }
    }
}

struct IngredientListView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(IngredientData())
    }
}
