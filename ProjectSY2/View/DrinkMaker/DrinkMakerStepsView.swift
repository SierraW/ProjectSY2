//
//  DrinkMakerStepsView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI
import Combine

class DrinkMakerStepsData: ObservableObject {
    @Published var name: String = ""
    @Published var steps: [Step] = []
    
    init(_ history: History) {
        if let name = history.container?.name {
            self.name = name
        }
        if let steps = history.steps as? Set<Step> {
            self.steps = Array(steps)
        }
    }
}

struct DrinkMakerStepsView: View {
    @EnvironmentObject var data: DrinkMakerStepsData
    var isShowingDetail = true
    
    var body: some View {
        VStack {
            HStack {
                Text("from \(data.name)")
                Spacer()
            }
            if isShowingDetail {
                Section {
                    ForEach(data.steps) { step in
                        Text(step.name ?? "Error itme")
                    }
                }
            }
        }
        .padding()
    }
}
