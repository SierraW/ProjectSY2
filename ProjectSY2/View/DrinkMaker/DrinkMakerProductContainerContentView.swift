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
    var isotopes: [Isotope] = []
    var name: String?
    var productContainer: ProductContainer?
    var steps: [Step] = []
    @State var selectedIsotope: Isotope?
    @Namespace var bottomId
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }
    
    init() {
        isLivePreview = true
    }
    
    init(from version: Version, showProdcutName: Bool = false, showsIsotopeMenu: Bool = false) {
        isLivePreview = false
        if showsIsotopeMenu, let isotopeSet = version.isotopes as? Set<Isotope> {
            isotopes = Array(isotopeSet)
        }
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
    
    init(from isotope: Isotope) {
        isLivePreview = false
        if let timestamp = isotope.timestamp {
            name = dateFormatter.string(from: timestamp)
        }
        if let pc = isotope.productContainer {
            productContainer = pc
        }
        if let stepSet = isotope.steps as? Set<Step> {
            steps = Array(stepSet)
        }
    }
    
    var body: some View {
        VStack {
            if isLivePreview {
                livePreview
            } else {
                review
            }
            if !isotopes.isEmpty {
                Divider()
                VStack {
                    Text("More version")
                    List {
                        ForEach(isotopes) { isotope in
                            Button(action: {
                                selectedIsotope = isotope
                            }, label: {
                                Text(dateFormatter.string(from: isotope.timestamp ?? Date()))
                            })
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedIsotope) { isotope in
            DrinkMakerProductContainerContentView(from: isotope)
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
                    .padding(.leading, 5)
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
