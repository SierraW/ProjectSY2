//
//  DrinkMakerProductContainerContentView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-05.
//

import SwiftUI

struct DrinkMakerProductContainerContentView: View {
    @EnvironmentObject var data: DrinkMakerData
    var isLivePreview: Bool
    var name: String?
    var productContainer: ProductContainer?
    var steps: [Step] = []
    @Namespace var bottomId
    
    init() {
        isLivePreview = true
    }
    
    init(from version: Version, showProdcutName: Bool) {
        isLivePreview = false
        name = showProdcutName ? "\(version.product?.name ?? "Error item") - \(version.name ?? "Error item")" : nil
        productContainer = version.productContainer
        if let steps = version.steps as? Set<Step> {
            self.steps = Array(steps).sorted(by: DrinkMakerComparator.compare(_:_:))
        }
    }
    
    init(name: String?, productContainer: ProductContainer, steps: [Step]) {
        isLivePreview = false
        self.name = name
        self.productContainer = productContainer
        self.steps = steps
    }
    
    var body: some View {
        if isLivePreview {
            livePreview
        } else {
            review
        }
    }
    
    @ViewBuilder
    var livePreview: some View {
        VStack {
            if let steps = data.steps {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack {
                            ForEach(steps, id: \.identifier) { step in
                                if let name = step.name {
                                    Text(name)
                                } else if let history = step.childHistory{
                                    DrinkMakerStepsView(isShowingDetail: true)
                                        .environmentObject(DrinkMakerStepsData(history))
                                }
                            }
                            Divider().id(bottomId)
                        }
                        .onChange(of: steps.count, perform: { _ in
                            withAnimation {
                                proxy.scrollTo(bottomId)
                            }
                        })
                    }
                }
            } else {
                Text("Empty")
            }
        }
    }
    
    @ViewBuilder
    var review: some View {
        VStack {
            if let name = name {
                Text(name)
                    .font(.caption)
            }
            if let productContainer = productContainer {
                HStack {
                    Text(productContainer.name ?? "Error item")
                    Spacer()
                }
            }
            if steps.isEmpty {
                Text("Empty")
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack {
                            ForEach(steps, id: \.identifier) { step in
                                if let name = step.name {
                                    Text(name)
                                } else if let history = step.childHistory{
                                    DrinkMakerStepsView(isShowingDetail: true)
                                        .environmentObject(DrinkMakerStepsData(history))
                                }
                            }
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
