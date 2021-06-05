//
//  DrinkMakerController.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import Foundation

class DrinkMakerController {
    var data: DrinkMakerData
    let viewContext = PersistenceController.shared.container.viewContext
    
    init(_ data: DrinkMakerData) {
        self.data = data
    }
    
    func creatorMode() {
        data.reset()
    }
    
    func pracitcePreparingMode() {
        data.reset()
        data.isLoading = true
        data.mode = .Practice
    }
    
    func practiceMode(version: Version) {
        data.reset()
        let question = Question(context: viewContext)
        question.version = version
        data.question = question
        data.mode = .Practice
    }
    
    func randomMode(serieses: [Series]) -> Bool {
        if serieses.count > 0 {
            var attemps = serieses.count * 2
            var version: Version? = nil
            while attemps > 0 && version == nil {
                attemps -= 1
                let selectedSeries = serieses.randomElement()
                if let products = selectedSeries?.products {
                    let product = Array(products as! Set<Product>).randomElement()
                    if let product = product, let versions = product.versions {
                        version = Array(versions as! Set<Version>).randomElement()
                    }
                }
            }
            if version != nil {
                data.reset()
                let question = Question(context: viewContext)
                question.version = version
                data.question = question
                data.mode = .Practice
                return true
            }
        }
        return false
    }
    
    func ExamMode(isRandomized: Bool, serieses: [Series]) -> Bool {
        if serieses.count > 0 {
            var versionPool: [Version] = []
            for series in serieses {
                if let products = series.products {
                    for product in products {
                        if let product = product as? Product, let versions = product.versions {
                            for version in versions {
                                if let version = version as? Version {
                                    versionPool.append(version)
                                }
                            }
                        }
                    }
                }
            }
            if versionPool.count > 0 {
                data.reset()
                if isRandomized {
                    versionPool.shuffle()
                }
                let exam = Exam(context: viewContext)
                exam.isRandomized = isRandomized
                for version in versionPool {
                    let question = Question(context: viewContext)
                    question.version = version
                    exam.addToQuestions(question)
                }
                data.exam = exam
                data.mode = .Exam
                return true
            }
        }
        return false
    }
    
    func nextQuestion() -> Bool {
        if let exam = data.exam, let questions = exam.questions as? Set<Question>, exam.answered < questions.count {
            data.question?.productContainer = data.productContainer
            for step in data.steps {
                data.question?.addToSteps(step)
            }
            for history in data.histories {
                data.question?.addToHistories(history)
            }
            data.question = Array(questions)[Int(exam.answered)]
            exam.answered = exam.answered + 1
            return true
        }
        return false
    }
    
    func checkError(for question: Question) -> Bool {
        if let version = question.version, let pc = question.productContainer, let steps = question.steps as? Set<Step>, let histories = question.histories as? Set<History> {
            if let aPC = version.productContainer, let aSteps = version.steps as? Set<Step>, let aHistories = version.histories as? Set<History> {
                if pc != aPC {
                    return false
                }
                if steps.count != aSteps.count {
                    return false
                }
                if histories.count != aHistories.count {
                    return false
                }
                
                let stepsArr = Array(steps)
                let aStepsArr = Array(aSteps)
                for index in stepsArr.indices {
                    let step = stepsArr[index]
                    let aStep = aStepsArr[index]
                    if step.name != aStep.name || step.index != aStep.index {
                        return false
                    }
                }
                
                // more checking
                
            }
        }
        
        return false
    }
    
    func submitVersion() {
        if let version = data.version {
            version.productContainer = data.productContainer
            for step in data.steps {
                version.addToSteps(step)
            }
            for history in data.histories {
                version.addToHistories(history)
            }
        }
    }
}
