//
//  DrinkMakerProductContainerContentView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-05.
//

import SwiftUI

struct DrinkMakerProductContainerContentView: View {
    var name: String?
    var productContainer: ProductContainer?
    var steps: [Step] = []
    var histories: [History] = []
    
    init(from version: Version) {
        name = "\(version.product?.name ?? "Error item") - \(version.name ?? "Error item")"
        productContainer = version.productContainer
        if let steps = version.steps as? Set<Step> {
            self.steps = Array(steps)
        }
        if let histories = version.histories as? Set<History> {
            self.histories = Array(histories)
        }
    }
    
    var body: some View {
        VStack {
            if let name = name {
                Text(name)
                    .font(.title)
            }
            if let productContainer = productContainer {
                HStack {
                    Text(productContainer.name ?? "Error item")
                        .font(.title3)
                    Spacer()
                }
                List {
                    ForEach(steps) { step in
                        if let name = step.name {
                            Text(name)
                        } else {
                            DrinkMakerStepsView(isShowingDetail: true)
                                .environmentObject(DrinkMakerStepsData(histories[Int(step.index)]))
                        }
                    }
                }
            } else {
                Text("Empty")
            }
        }
    }
}
