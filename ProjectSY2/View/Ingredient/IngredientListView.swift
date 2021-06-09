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
    @Binding var selectedIngredients: [Ingredient]
    var showTitle = true
    var editDisabled = false
    var selected: ((Ingredient) -> Void)?
    
    var body: some View {
        ZStack {
            VStack {
                if showTitle {
                    HStack {
                        Text("Ingredient")
                            .font(.title)
                        Spacer()
                        Button("Add") {
                            ingredientData.set(nil)
                        }
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
                    if selected == nil {
                        Button(item.name ?? "Error item") {
                            ingredientData.set(item)
                        }
                    } else {
                        HStack {
                            Text(item.name ?? "Error item")
                                .gesture(TapGesture().onEnded({ _ in
                                    selected!(item)
                                }))
                            Spacer()
                            if !selectedIngredients.isEmpty && selectedIngredientsContains(item){
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .gesture(TapGesture().onEnded({ _ in
                                    ingredientData.set(item)
                                }))
                        }
                    }
                }
                .onDelete(perform: removeIngredients)
                .deleteDisabled(editDisabled)
            }
        }
    }

    private func selectedIngredientsContains(_ ingredient: Ingredient) -> Bool {
        return selectedIngredients.contains(ingredient)
    }
    
    private func removeIngredients(_ indexSet: IndexSet) {
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
        IngredientListView(selectedIngredients: .constant([]))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(IngredientData())
    }
}
