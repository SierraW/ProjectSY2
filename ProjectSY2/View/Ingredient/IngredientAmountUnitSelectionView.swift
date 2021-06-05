//
//  IngredientAmountUnitSelectionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-02.
//

import SwiftUI

struct IngredientAmountUnitSelectionView: View {
    var selected: (Ingredient, IngredientUnit, IngredientUnitAmount) -> Void
    @State var selectedIngredient: Ingredient?
    
    var body: some View {
        if selectedIngredient == nil {
            IngredientListView { ing in
                set(ing)
            }
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(IngredientData())
            
        } else {
            VStack {
                HStack {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                        .gesture(TapGesture().onEnded({ _ in
                            set(nil)
                        }))
                    Text(selectedIngredient?.name ?? "Error item")
                    Spacer()
                }
                .padding()
                AmountAndUnitSelectionView { unit, amount in
                    selected(selectedIngredient!, unit, amount)
                }
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(AmountAndUnitSelectionData(selectedIngredient!))
            }
        }
    }
    
    func set(_ ingredient: Ingredient?) {
        self.selectedIngredient = ingredient
    }
}

struct IngredientAmountUnitSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientAmountUnitSelectionView { _, _, _ in
            // gugu
        }
    }
}
