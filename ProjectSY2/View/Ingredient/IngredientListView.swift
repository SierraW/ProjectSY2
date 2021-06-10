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
    @State var editingIngredient: Ingredient?
    @State var name: String = ""
    
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
                    if let ingredient = editingIngredient, ingredient == item {
                        HStack {
                            Image(systemName: "pencil")
                            TextField("Name of the ingredient", text: $name) { _ in} onCommit: {
                                submit(ingredient)
                            }
                            .frame(width: 300, height: 50, alignment: .center)
                            .transition(.opacity)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text(item.name ?? "Error item")
                                .frame(width: 300, height: 40, alignment: .center)
                            Spacer()
                        }
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                if let selected = selected {
                                    selected(item)
                                } else {
                                    ingredientData.set(item)
                                }
                            }
                        }
                        .onLongPressGesture {
                            withAnimation {
                                set(item)
                            }
                        }
                    }
                }
                .onDelete(perform: removeIngredients)
                .deleteDisabled(editDisabled)
            }
        }
    }
    
    private func set(_ ingredient: Ingredient?) {
        if !editDisabled {
            editingIngredient = ingredient
            name = ingredient?.name ?? ""
        }
    }
    
    private func submit(_ ingredient: Ingredient) {
        if name == "" {
            set(nil)
            return
        }
        ingredient.name = name
        set(nil)
        save()
    }

    private func selectedIngredientsContains(_ ingredient: Ingredient) -> Bool {
        return selectedIngredients.contains(ingredient)
    }
    
    private func removeIngredients(_ indexSet: IndexSet) {
        for index in indexSet {
            let ingredient = ingredients[index]
            viewContext.delete(ingredient)
        }
        save()
    }
    
    private func save() {
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
