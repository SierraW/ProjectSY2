//
//  DrinkMakerExamResultListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import SwiftUI
import Combine

class DrinkMakerExamResultData: ObservableObject {
    @Published var selectedQuestion: Question?
    
}

struct DrinkMakerExamResultListView: View {
    @EnvironmentObject var data: DrinkMakerExamResultData
    var products: [Product] = []
    var questions: [Product: [Question]] = [:]
    @State var numberOfCorrectQuestion = 0
    var questionSet: Set<Question> = Set()
    
    init(_ data: DrinkMakerData) {
        if let exam = data.exam, let questionSet = exam.questions as? Set<Question> {
            self.questionSet = questionSet
            for question in questionSet {
                if let product = question.version?.product {
                    if self.questions[product] == nil {
                        products.append(product)
                        self.questions[product] = []
                    }
                    self.questions[product]!.append(question)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Exam Result")
                    .font(.title2)
                    .padding(.trailing, 10)
                DrinkMakerExamResultScoreWidgit(numberOfTotalQuestion: questionSet.count, numberOfCorrectQuestion: $numberOfCorrectQuestion)
                    .onAppear(perform: {
                        numberOfCorrectQuestion = countCorrect()
                    })
                    .frame(width: 100, height: 30, alignment: .center)
            }
            List {
                ForEach(products) { product in
                    DrinkMakerExamResultListViewCell(product: product, questions: questions[product] ?? [])
                        .environmentObject(data)
                }
            }
            .sheet(item: $data.selectedQuestion) { question in
                VStack {
                    DrinkMakerComparisonView(from: question)
                    DrinkMakerResultCorrectionBar(question: question) {
                        numberOfCorrectQuestion = countCorrect()
                    }
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                }
            }
        }
    }
    
    private func countCorrect() -> Int {
        var counter = 0
        questionSet.forEach { question in
            if question.isCorrect {
                counter += 1
            }
        }
        return counter
    }
}

struct DrinkMakerExamResultListView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerExamResultListView(DrinkMakerData())
            .environmentObject(DrinkMakerExamResultData())
    }
}
