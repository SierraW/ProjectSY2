//
//  DrinkMakerIsotopeController.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import Foundation

class DrinkMakerIsotopeController {
    func getId(_ containerName: String?, _ steps: Set<Step>) -> Int {
        var hasher = Hasher()
        hasher.combine(containerName)
        steps.sorted(by: DrinkMakerComparator.compare(_:_:)).forEach { step in
            if let name = step.name {
                hasher.combine(name)
            } else if let history = step.history, let stepSet = history.steps as? Set<Step> {
                hasher.combine(getId(history.container?.name, stepSet))
            }
        }
        return hasher.finalize()
    }
    
    func getId(_ productContainer: ProductContainer?, _ stepSet: NSSet?) -> Int? {
        if let pc = productContainer, let stepSet = stepSet as? Set<Step> {
            return getId(pc.name, stepSet)
        }
        return nil
    }
    
    func assignIdentifier(to isotope: Isotope) -> Bool {
        if let id = getId(isotope.productContainer, isotope.steps) {
            isotope.identifier = Int64(id)
            return true
        }
        return false
    }
    
    func find(question answer: Question) -> Isotope? {
        if let id = getId(answer.productContainer, answer.steps), let version = answer.version, let isotopes = version.isotopes as? Set<Isotope> {
            return isotopes.first { isotope in
                isotope.identifier == id
            }
        }
        return nil
    }
    
    func markAnswerRight(from question: Question, with isotope: Isotope) -> Bool{
        if find(question: question) != nil {
            print("Must be some error at comparator - DMIsotopeController")
            return false
        }
        if let version = question.version {
            isotope.timestamp = Date()
            isotope.productContainer = question.productContainer
            isotope.steps = question.steps
            if !assignIdentifier(to: isotope) {
                print("Cannot assign identifier, fix immediately - DMIsotopeController")
                return false
            }
            version.addToIsotopes(isotope)
            question.isCorrect = true
            return true
        } else {
            print("Cannot find version from question - DMIsotopeController")
            return false
        }
    }
    
    func markAnswerWrong(from question: Question) -> Bool{
        if let version = question.version, let isotope = find(question: question) {
            version.removeFromIsotopes(isotope)
            question.isCorrect = false
            return true
        }
        return false
    }
}
