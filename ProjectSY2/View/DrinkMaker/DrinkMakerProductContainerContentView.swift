//
//  DrinkMakerProductContainerContentView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-05.
//

import SwiftUI

struct DrinkMakerProductContainerContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var data: DrinkMakerData
    var isLivePreview: Bool
    @State var isotopes: [Isotope] = []
    var name: String?
    var productContainer: ProductContainer?
    var steps: [Step] = []
    var creativeModeAction: ((Version) -> Void)?
    var version: Version?
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
    
    init(from version: Version, showProdcutName: Bool = false, showsIsotopeMenu: Bool = false, creativeModeAction: ((Version) -> Void)? = nil) {
        isLivePreview = false
        self.creativeModeAction = creativeModeAction
        self.version = version
        if showsIsotopeMenu, let isotopeSet = version.isotopes as? Set<Isotope> {
            _isotopes = State(initialValue: Array(isotopeSet))
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
                HStack(spacing: 0) {
                    Text("Use")
                    Text(" Creative Mode ")
                        .onTapGesture {
                            if let version = version, let creativeModeAction = creativeModeAction {
                                withAnimation {
                                    creativeModeAction(version)
                                }
                            }
                        }
                        .foregroundColor(creativeModeAction == nil ? .black : .blue)
                    Text("to modify main answer")
                }
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
                        .onDelete(perform: removeIsotope(atOffset:))
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
                HStack {
                    Text(name)
                    Spacer()
                }
                .padding()
            }
            if let productContainer = productContainer {
                Text(productContainer.name ?? "Error item")
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
    
    private func removeIsotope(atOffset indexSet: IndexSet) {
        if !isotopes.isEmpty {
            for index in indexSet {
                viewContext.delete(isotopes[index])
            }
            isotopes.remove(atOffsets: indexSet)
            do {
                try viewContext.save()
            } catch {
                
            }
        }
    }
}
