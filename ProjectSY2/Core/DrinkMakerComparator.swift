//
//  DrinkMakerComparator.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-06.
//

import Foundation

class DrinkMakerComparator {
    static func compare(_ lhs: Set<Step>, _ rhs: Set<Step>) -> Bool {
        let lhsArr = Array(lhs).sorted { lhs, rhs in
            lhs.identifier > rhs.identifier
        }
        let rhsArr = Array(rhs).sorted { lhs, rhs in
            lhs.identifier > rhs.identifier
        }
        if lhsArr.count != rhsArr.count {
            return false
        }
        for index in lhsArr.indices {
            if lhsArr[index].name == nil && rhsArr[index].name == nil, let lhsStps = lhsArr[index].history?.steps as? Set<Step>, let rhsStps = rhsArr[index].history?.steps as? Set<Step> {
                if !compare(lhsStps, rhsStps) {
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
