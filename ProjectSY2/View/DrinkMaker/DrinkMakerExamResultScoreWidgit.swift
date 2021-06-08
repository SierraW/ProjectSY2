//
//  DrinkMakerExamResultScoreWidgit.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import SwiftUI

struct DrinkMakerExamResultScoreWidgit: View {
    var numberOfTotalQuestion = 0
    var numberOfCorrectQuestion = 0
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
            Text(isShowingPercentage ? percentage : "\(numberOfCorrectQuestion) / \(numberOfTotalQuestion)")
                .foregroundColor(ratio > 0.9 ? .green : .red)
                .font(.title2)
        })
    }
}

struct DrinkMakerExamResultScoreWidgit_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerExamResultScoreWidgit()
    }
}
