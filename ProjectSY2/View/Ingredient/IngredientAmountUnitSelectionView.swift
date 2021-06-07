//
//  IngredientAmountUnitSelectionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-02.
//

import SwiftUI

struct IngredientAmountUnitSelectionView: View {
    var ingredients: [Ingredient]
    var selected: (Ingredient, IngredientUnit, IngredientUnitAmount) -> Void
    @State var selectedIngredient: Ingredient?
    @State var focusOnIngredients = false
    
    var body: some View {
        HStack {
            if !focusOnIngredients, let selectedIngredient = selectedIngredient {
                Button(action: {
                    focusOnIngredients = true
                }, label: {
                    Text(selectedIngredient.name ?? "Error item")
                        .rotationEffect(.degrees(270))
                        .frame(width: 100, height: 10, alignment: .center)
                })
                .frame(width: 10, height: 100, alignment: .center)
                AmountAndUnitSelectionView { unit, amount in
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
                    Button(action: {
                        focusOnIngredients = false
                    }, label: {
                        Text("Amount & Unit")
                            .rotationEffect(.degrees(90))
                            .frame(width: 200, height: 15, alignment: .center)
                    })
                    .frame(width: 15, height: 200, alignment: .center)
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

