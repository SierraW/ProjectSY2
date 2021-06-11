//
//  DrinkMakerContainerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-27.
//

import SwiftUI

struct DrinkMakerContainerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var data: DrinkMakerData
    @State var isSelectedIngredient = true
    @State var selectedIngredient: Ingredient? = nil
    @State var selectedOperation: Operation? = nil
    var showActionField = true
    @Namespace var bottomId
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(data.historyContainer?.name ?? "Container")
                    Spacer()
                }
                Divider()
                containerStepList
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 200, maxHeight: 200, alignment: .center)
                if showActionField {
                    selectionMenu
                        .frame(minWidth: 100, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
                    mainInteractingSection
                        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 450, idealHeight: 450, maxHeight: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .onAppear(perform: {
            withAnimation {
                if data.historyOperations.isEmpty && !data.historyIngredients.isEmpty {
                    isSelectedIngredient = true
                } else if data.historyIngredients.isEmpty && !data.historyOperations.isEmpty {
                    isSelectedIngredient = false
                }
            }
        })
    }
    
    @ViewBuilder
    var containerStepList: some View {
        if data.historySteps.isEmpty {
            Text("Empty Container - Click to add steps")
        } else {
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(data.historySteps) { step in
                            Text(step.name ?? "Error item")
                        }
                        Divider().id(bottomId)
                    }
                    .onChange(of: data.historySteps, perform: { value in
                        withAnimation {
                            proxy.scrollTo(bottomId)
                        }
                    })
                }
            }
        }
    }
    
    @ViewBuilder
    var selectionMenu: some View {
        HStack {
            Spacer()
            if !data.historyIngredients.isEmpty {
                Button(action: {
                    setFocus()
                }, label: {
                    Text("Ingredients")
                        .foregroundColor(.blue)
                })
            } else {
                Text("Ingredients")
                    .foregroundColor(.gray)
            }
            Spacer()
            Divider()
            Spacer()
            if !data.historyOperations.isEmpty {
                Button(action: {
                    setFocus()
                }, label: {
                    Text("Operations")
                        .foregroundColor(.blue)
                })
            } else {
                Text("Operations")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var ingredientAction: some View {
        HStack {
            if selectedIngredient == nil {
                List {
                    ForEach(data.historyIngredients) { ingredient in
                        Button(ingredient.name ?? "Error item") {
                            selectedIngredient = ingredient
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .gesture(TapGesture().onEnded({ _ in
                                selectedIngredient = nil
                            }))
                        Text(selectedIngredient!.name ?? "Error item")
                        Spacer()
                    }
                    AmountAndUnitSelectionView() { unit, amount in
                        let step = Step(context: viewContext)
                        step.name = "\(selectedIngredient?.name ?? "Error item") \(amount.name ?? "Error item")\(unit.name ?? "Error item")"
                        add(step)
                        selectedIngredient = nil
                    }
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(AmountAndUnitSelectionData(selectedIngredient!))
                }
            }
            
        }
    }
    
    @ViewBuilder
    var operationAction: some View {
        List {
            ForEach(data.historyOperations) { operation in
                Button(action: {
                    let step = Step(context: viewContext)
                    step.name = operation.name
                    add(step)
                }, label: {
                    Text(operation.name ?? "Error item")
                })
            }
        }
    }
    
    @ViewBuilder
    var mainInteractingSection: some View {
        if !data.historyIngredients.isEmpty || !data.historyOperations.isEmpty {
            if isSelectedIngredient {
                ingredientAction
            } else {
                operationAction
            }
        } else {
            VStack {
                Spacer()
                Text("Not available")
                Spacer()
            }
        }
    }
    
    private func setFocus() {
        if !data.historyIngredients.isEmpty && !data.historyOperations.isEmpty {
            isSelectedIngredient.toggle()
        }
    }
    
    private func add(_ step: Step) {
        if let history = data.history {
            step.identifier = data.generateId()
            history.addToSteps(step)
        }
        data.historySteps.append(step)
    }
}

struct DrinkMakerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerContainerView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(DrinkMakerData())
    }
}
