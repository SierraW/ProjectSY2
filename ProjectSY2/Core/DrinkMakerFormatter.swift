//
//  DrinkMakerFormatter.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-11.
//

import Foundation

class DrinkMakerFormatter {
    static func format(_ ingredient: Ingredient, _ unit: IngredientUnit, _ amount: IngredientAmount) -> String {
        return "\(ingredient.name ?? "Error item") \(amount.name ?? "Error item") \(unit.name ?? "Error item")"
    }
    
    static func format(_ operation: Operation) -> String {
        return operation.name ?? "Error itme"
    }
}
