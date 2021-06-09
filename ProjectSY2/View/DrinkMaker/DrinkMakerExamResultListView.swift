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
    
    init(_ data: DrinkMakerData) {
        if let exam = data.exam, let questionSet = exam.questions as? Set<Question> {
            let questions = Array(questionSet)
            for question in questions {
                if let product = question.version?.product {
                    products.append(product)
                    if self.questions[product] == nil {
                        self.questions[product] = []
                    }
                    self.questions[product]!.append(question)
                }
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(products) { product in
                DrinkMakerExamResultListViewCell(product: product, questions: questions[product] ?? [])
                    .environmentObject(data)
            }
        }
        .sheet(item: $data.selectedQuestion) { question in
            VStack {
                DrinkMakerComparisonView(from: question)
                DrinkMakerResultCorrectionBar(question: question)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            }
        }
    }
}

struct DrinkMakerExamResultListView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerExamResultListView(DrinkMakerData())
    }
}
