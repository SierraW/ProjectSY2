//
//  DrinkMakerProductContainerContentView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-05.
//

import SwiftUI

struct DrinkMakerProductContainerContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var isotopes: [Isotope] = []
    var name: String?
    var productContainer: ProductContainer?
    var steps: [Step] = []
    var practiceModeAction: ((Version) -> Void)?
    var creativeModeAction: ((Version) -> Void)?
    var version: Version?
    @State var selectedIsotope: Isotope?
    @Namespace var bottomId
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }
    
    init(from version: Version, showProductName: Bool = false, showsIsotopeMenu: Bool = false, practiceModeAction: ((Version) -> Void)? = nil, creativeModeAction: ((Version) -> Void)? = nil) {
        self.practiceModeAction = practiceModeAction
        self.creativeModeAction = creativeModeAction
        self.version = version
        if showsIsotopeMenu, let isotopeSet = version.isotopes as? Set<Isotope> {
            _isotopes = State(initialValue: Array(isotopeSet))
        }
        name = showProductName ? "\(version.product?.name ?? "Error item") - \(version.name ?? "Error item")" : nil
        productContainer = version.productContainer
        if let steps = version.steps as? Set<Step> {
            self.steps = Array(steps).sorted(by: DrinkMakerComparator.compare(_:_:))
        }
    }
    
    init(name: String?, productContainer: ProductContainer, steps unsortedStepSet: Set<Step>) {
        self.name = name
        self.productContainer = productContainer
        self.steps = unsortedStepSet.sorted(by: DrinkMakerComparator.compare(_:_:))
    }
    
    init(from isotope: Isotope) {
        if let timestamp = isotope.timestamp {
            name = dateFormatter.string(from: timestamp)
        }
        if let pc = isotope.productContainer {
            productContainer = pc
        }
        if let stepSet = isotope.steps as? Set<Step> {
            steps = stepSet.sorted(by: DrinkMakerComparator.compare(_:_:))
        }
    }
    
    var body: some View {
        VStack {
            review
                .padding()
            VStack {
                if let practiceModeAction = practiceModeAction {
                    Text("Pratice Now")
                        .onTapGesture {
                            if let version = version {
                                withAnimation {
                                    practiceModeAction(version)
                                }
                            }
                        }
                        .foregroundColor(.blue)
                }
                if let creativeModeAction = creativeModeAction {
                    HStack(spacing: 0) {
                        Text("Or use")
                        Text(" Creative Mode ")
                            .onTapGesture {
                                if let version = version {
                                    withAnimation {
                                        creativeModeAction(version)
                                    }
                                }
                            }
                            .foregroundColor(.blue)
                        Text("to modify the answer")
                    }
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
    var review: some View {
        VStack {
            if let name = name {
                Text(name)
                    .padding(.horizontal, 7)
            }
            if let productContainer = productContainer {
                HStack {
                    Text(productContainer.name ?? "Error item")
                        .bold()
                    Spacer()
                }
            }
            if steps.isEmpty {
                Text("Empty")
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(steps) { step in
                            if let name = step.name {
                                HStack {
                                    Text(name)
                                        .padding(.vertical, 7)
                                    Spacer()
                                }
                            } else if let history = step.childHistory{
                                DrinkMakerStepsView(showPadding: true)
                                    .environmentObject(DrinkMakerStepsData(history))
                            }
                        }
                        Divider()
                    }
                }
                Spacer()
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
