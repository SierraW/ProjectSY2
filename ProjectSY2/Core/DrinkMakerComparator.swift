//
//  DrinkMakerComparator.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-06.
//

import Foundation

class DrinkMakerComparator {
    static func compare(_ lhs: Step, _ rhs: Step) -> Bool {
        return lhs.identifier < rhs.identifier
    }
    
    static func compare(_ lhs: Ingredient, _ rhs: Ingredient) -> Bool {
        return lhs.name?.compare(rhs.name ?? "") == .orderedAscending
    }
    
    static func compare(_ lhs: Operation, _ rhs: Operation) -> Bool {
        return lhs.name?.compare(rhs.name ?? "") == .orderedAscending
    }
    
    static func compare(_ lhs: IngredientUnit, _ rhs: IngredientUnit) -> Bool {
        return lhs.name?.compare(rhs.name ?? "") == .orderedAscending
    }
    
    static func compare(_ lhs: IngredientAmount, _ rhs: IngredientAmount) -> Bool {
        return lhs.name?.compare(rhs.name ?? "") == .orderedAscending
    }
    
    static func compare(_ lhs: Product, _ rhs: Product) -> Bool {
        return lhs.name?.compare(rhs.name ?? "") == .orderedAscending
    }
    
    static func compare(_ lhs: Version, _ rhs: Version) -> Bool {
        return lhs.name?.compare(rhs.name ?? "") == .orderedAscending
    }
    
    static func compare(_ lhs: Set<Step>, _ rhs: Set<Step>) -> Bool {
        let lhsArr = lhs.sorted(by: compare(_:_:))
        let rhsArr = rhs.sorted(by: compare(_:_:))
        if lhsArr.count != rhsArr.count {
            return false
        }
        for index in lhsArr.indices {
            if lhsArr[index].name == nil && rhsArr[index].name == nil {
                if let lhsStps = lhsArr[index].history?.steps as? Set<Step>, let rhsStps = rhsArr[index].history?.steps as? Set<Step>, let lhsCon = lhsArr[index].history?.container, let rhsCon = rhsArr[index].history?.container, lhsCon == rhsCon {
                    if !compare(lhsStps, rhsStps) {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                if lhsArr[index].name != rhsArr[index].name {
                    return false
                }
            }
        }
        return true
    }
}
