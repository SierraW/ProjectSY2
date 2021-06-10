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
    let isotopeController = DrinkMakerIsotopeController()
    
    init(_ data: DrinkMakerData) {
        self.data = data
    }
    
    func creatorMode() {
        data.reset()
    }
    
    func creatorMode(with version: Version) {
        data.reset()
        data.version = version
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
    
    func startOver() {
        data.productContainer = nil
        data.identifierGenerator = 0
        data.steps = []
        data.history = nil
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
                let _ = nextQuestion()
                return true
            }
        }
        return false
    }
    
    func submitQuestion() {
        if let question = data.question, let productContainer = data.productContainer{
            question.answered = true
            question.productContainer = productContainer
            for step in data.steps {
                question.addToSteps(step)
            }
            question.isCorrect = isCorrect(for: question)
        }
    }
    
    func nextQuestion() -> Bool {
        submitQuestion()
        if let exam = data.exam, let questions = exam.questions as? Set<Question>, let question = questions.first(where: { question in
            !question.answered
        }) {
            exam.answered = exam.answered + 1
            data.question = question
            return true
        }
        return false
    }
    
    private func isCorrect(for question: Question) -> Bool {
        if let version = question.version, let productContainer = question.productContainer , let steps = question.steps as? Set<Step> {
            if let ansPC = version.productContainer, let ansSteps = version.steps as? Set<Step>{
                if productContainer == ansPC && DrinkMakerComparator.compare(steps, ansSteps) {
                    return true
                } else if let _ = isotopeController.find(question: question) {
                    return true
                }
            }
        }
        return false
    }
    
    func submitVersion() {
        if let version = data.version {
            version.productContainer = data.productContainer
            if let steps = version.steps {
                version.removeFromSteps(steps)
            }
            for step in data.steps {
                version.addToSteps(step)
            }
        }
    }
}
