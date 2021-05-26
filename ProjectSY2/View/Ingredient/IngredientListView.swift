//
//  IngredientListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct IngredientListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Ingredient.name, ascending: true)],
                  animation: .default)
    var ingredients: FetchedResults<Ingredient>
    var allowEdit = false
    @State var isShowingIngredientAdditionView = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Ingredient")
                        .font(.title)
                        .fontWeight(.heavy)
                    Spacer()
                    Button("Add") {
                        isShowingIngredientAdditionView = true
                    }
                }
                listView
                
            }
            .padding()
        }
        .sheet(isPresented: $isShowingIngredientAdditionView, content: {
            IngredientAdditionView()
                .environment(\.managedObjectContext, viewContext)
        })
    }
    
    @ViewBuilder
    var listView: some View {
        if ingredients.isEmpty {
            Text("Empty")
                .font(.headline)
        } else {
            List {
                ForEach(ingredients) { item in
                    Text(item.name ?? "Error item")
                }
                .onDelete(perform: removeIngredients)
                .deleteDisabled(allowEdit)
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
    }
}
