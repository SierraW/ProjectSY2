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
                    withAnimation {
                        focusOnIngredients = true
                    }
                }, label: {
                    HStack {
                        Text(selectedIngredient.name ?? "Error item")
                            .fontWeight(.heavy)
                            .foregroundColor(.gray)
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.gray)
                    }
                    .rotationEffect(.degrees(270))
                    .frame(width: 200, height: 20, alignment: .center)
                })
                .frame(width: 20, height: 100, alignment: .center)
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
                        withAnimation {
                            focusOnIngredients = false
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.up.circle")
                                .foregroundColor(.gray)
                            Text("Amount & Unit")
                                .fontWeight(.heavy)
                                .foregroundColor(.gray)
                        }
                        .rotationEffect(.degrees(90))
                        .frame(width: 200, height: 20, alignment: .center)
                    })
                    .frame(width: 20, height: 200, alignment: .center)
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

