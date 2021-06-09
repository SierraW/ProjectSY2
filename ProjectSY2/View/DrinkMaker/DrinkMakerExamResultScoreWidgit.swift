//
//  DrinkMakerExamResultScoreWidgit.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import SwiftUI

struct DrinkMakerExamResultScoreWidgit: View {
    var numberOfTotalQuestion = 0
    @Binding var numberOfCorrectQuestion: Int
    @State var isShowingPercentage = true
    var ratio: Double {
        Double(numberOfCorrectQuestion) / Double(numberOfTotalQuestion)
    }
    var percentage: String {
        String(format: "%.1f", ratio * 100) + "%"
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                isShowingPercentage.toggle()
            }
        }, label: {
            HStack {
                Spacer()
                Text(isShowingPercentage ? percentage : "\(numberOfCorrectQuestion) / \(numberOfTotalQuestion)")
                    .foregroundColor(ratio > 0.9 ? .green : .red)
                    .font(.title2)
                    .transition(.opacity)
                Spacer()
            }
        })
    }
}

struct DrinkMakerExamResultScoreWidgit_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerExamResultScoreWidgit(numberOfCorrectQuestion: .constant(0))
    }
}
