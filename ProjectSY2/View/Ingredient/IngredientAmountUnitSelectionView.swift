//
//  IngredientAmountUnitSelectionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-02.
//

import SwiftUI

struct IngredientAmountUnitSelectionView: View {
    var ingredients: [Ingredient]
    var selected: (Ingredient, IngredientUnit, IngredientAmount) -> Void
    @State var selectedIngredient: Ingredient?
    @State var focusOnIngredients = false
    
    var body: some View {
        HStack {
            if !focusOnIngredients, let selectedIngredient = selectedIngredient {
                HStack {
                    Text(selectedIngredient.name ?? "Error item")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .frame(width: 200, alignment: .trailing)
                    Image(systemName: "arrow.up.circle")
                        .foregroundColor(.gray)
                }
                .rotationEffect(.degrees(270))
                .frame(width: 20, height: 250, alignment: .center)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        focusOnIngredients = true
                    }
                }
                AmountAndUnitSelectionView(allowEdit: false) { unit, amount in
                    focusOnIngredients = true
                    selected(selectedIngredient, unit, amount)
                }
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(AmountAndUnitSelectionData(selectedIngredient))
            } else if ingredients.isEmpty {
                Text("Empty")
            } else {
                List {
                    ForEach(ingredients) { ingredient in
                        Button(action: {
                            if let selectedIngredient = selectedIngredient, selectedIngredient == ingredient {
                                set(nil)
                            } else {
                                set(ingredient)
                            }
                        }, label: {
                            Text(ingredient.name ?? "Error item")
                        })
                    }
                }
                if let _ = selectedIngredient {
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.gray)
                        Text("Amount & Unit")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(width: 200, alignment: .leading)
                    }
                    .rotationEffect(.degrees(90))
                    .frame(width: 20, height: 250, alignment: .center)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            focusOnIngredients = false
                        }
                    }
                }
            }
        }
    }
    
    func set(_ ingredient: Ingredient?) {
        if ingredient == nil {
            if focusOnIngredients {
                focusOnIngredients = false
                return
            }
            focusOnIngredients = true
        } else {
            focusOnIngredients = false
        }
        self.selectedIngredient = ingredient
    }
}

