//
//  DrinkMakerExamResultListViewCell.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import SwiftUI

struct DrinkMakerExamResultListViewCell: View {
    @EnvironmentObject var data: DrinkMakerExamResultData
    @State var isExpanded = false
    var product: Product
    var questions: [Question]
    var numberOfCorrectAnswer: Int {
        var count = 0
        questions.forEach { question in
            if question.isCorrect {
                count += 1
            }
        }
        return count
    }
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }, label: {
                HStack {
                    Text(product.name ?? "Error item")
                    Spacer()
                    Text("\(numberOfCorrectAnswer) / \(questions.count)")
                        .foregroundColor(numberOfCorrectAnswer == questions.count ? .green : .red)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding()
                }
            })
            if isExpanded {
                ScrollView {
                    ForEach(questions) { question in
                        HStack {
                            Button(action: {
                                data.selectedQuestion = question
                            }, label: {
                                Text("\(question.version?.product?.name ?? "Error item") \(question.version?.name ?? "Error item")")
                                Spacer()
                                Text(question.isCorrect ? "Correct" : "Wrong")
                                    .foregroundColor(question.isCorrect ? .green : .red)
                            })
                        }
                    }
                }
            }
        }
    }
}
