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
            self.steps = Array(steps).sorted(by: DrinkMakerComparator.compare(_:_:))
        }
    }
}

struct DrinkMakerStepsView: View {
    @EnvironmentObject var data: DrinkMakerStepsData
    var showPadding = false
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.blue)
                .frame(width: 4)
                .cornerRadius(15)
                .padding(.trailing, showPadding ? 10 : 5)
            VStack {
                HStack {
                    if showPadding {
                        Text("from \(data.name)")
                            .bold()
                    } else {
                        Text("from \(data.name)")
                            .bold()
                    }
                    Spacer()
                }
                Section {
                    ForEach(data.steps) { step in
                        HStack {
                            if showPadding {
                                Text(step.name ?? "Error itme")
                                    .padding(.vertical, 7)
                            } else {
                                Text(step.name ?? "Error itme")
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 7)
    }
}

struct DrinkMakerStepsView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerStepsView()
    }
}
