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
    
    @State var showToolContainerView = false
    @State var toolContainer: History?
    @State var toolContainerSteps: [Step] = []
    @State var isSelectedToolContainerIngredient = true
    
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
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 200, maxHeight: .infinity, alignment: .center)
                if showActionField {
                    if !showToolContainerView {
                        selectionMenu
                            .frame(minWidth: 100, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
                        mainInteractingSection
                            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 320, idealHeight: 320, maxHeight: 500, alignment: .center)
                    }
                    toolContainerTitle
                    if showToolContainerView {
                        toolContainerView
                            .frame(height: 200)
                        if toolContainer != nil {
                            toolContainerActionMenu
                                .frame(height: 50)
                            toolContainerActionView
                                .frame(height: 320)
                        }
                    }
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
    var toolContainerTitle: some View {
        LabelledDivider(label: Text("Supporting Container"))
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    showToolContainerView.toggle()
                }
            }
    }
    
    @ViewBuilder
    var toolContainerView: some View {
        if let toolContainer = toolContainer {
            VStack {
                HStack {
                    Text(toolContainer.container?.name ?? "Container")
                        .foregroundColor(.blue)
                    Spacer()
                }
                DrinkMakerContainerContentLivePreviewView(steps: $toolContainerSteps)
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 200, maxHeight: .infinity, alignment: .center)
            }
        } else {
            ContainerListView(showTitle: false, isDeleteDisabled: true) { container in
                withAnimation {
                    let history = History(context: viewContext)
                    history.container = container
                    toolContainerSteps = []
                    toolContainer = history
                }
            }
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(ContainerData())
        }
    }
    
    @ViewBuilder
    var toolContainerActionMenu: some View {
        HStack {
            Section {
                if let toolContainer = toolContainer?.container, let ingredients = toolContainer.ingredients, ingredients.count > 0 {
                    Text("Ingredients")
                        .foregroundColor(.blue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isSelectedToolContainerIngredient = true
                        }
                } else {
                    Text("Ingredients")
                        .foregroundColor(.gray)
                }
            }
            Divider()
            Section {
                if let toolContainer = toolContainer?.container, let operations = toolContainer.operations, operations.count > 0 {
                    Text("Operations")
                        .foregroundColor(.blue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isSelectedToolContainerIngredient = false
                        }
                } else {
                    Text("Operations")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    @ViewBuilder
    var toolContainerActionView: some View {
        VStack {
            Section {
                if isSelectedToolContainerIngredient {
                    if let history = toolContainer, let toolContainer = history.container, let ingredientSet = toolContainer.ingredients as? Set<Ingredient>, ingredientSet.count > 0 {
                        IngredientAmountUnitSelectionView(ingredients: ingredientSet.sorted(by: DrinkMakerComparator.compare(_:_:))) { ingredient, unit, amount in
                            let step = Step(context: viewContext)
                            step.identifier = data.generateId()
                            step.name = DrinkMakerFormatter.format(ingredient, unit, amount)
                            history.addToSteps(step)
                            toolContainerSteps.append(step)
                        }
                    } else {
                        Text("Empty")
                            .foregroundColor(.gray)
                    }
                } else {
                    if let history = toolContainer, let toolContainer = history.container, let operationSet = toolContainer.operations as? Set<Operation>, operationSet.count > 0 {
                        let operationList = operationSet.sorted(by: DrinkMakerComparator.compare(_:_:))
                        ScrollView {
                            LazyVStack {
                                ForEach(operationList) {operation in
                                    Button(action: {
                                        let step = Step(context: viewContext)
                                        step.identifier = data.generateId()
                                        step.name = DrinkMakerFormatter.format(operation)
                                        history.addToSteps(step)
                                        toolContainerSteps.append(step)
                                    }, label: {
                                        Text(operation.name ?? "Error item")
                                    })
                                }
                            }
                        }
                    }
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            if let _ = data.historyContainer, let history = toolContainer {
                                let step = Step(context: viewContext)
                                step.identifier = data.generateId()
                                step.childHistory = history
                                data.historySteps.append(step)
                                self.toolContainer = nil
                            }
                        }
                    }, label: {
                        Text("Pour to \(data.historyContainer?.name ?? "Container")")
                    })
                    .padding(.trailing, 10)
                    Button(action: {
                        withAnimation {
                            toolContainer = nil
                        }
                    }, label: {
                        Text("Discard")
                            .foregroundColor(.red)
                    })
                }
            }
        }
    }
    
    @ViewBuilder
    var containerStepList: some View {
        if data.historySteps.isEmpty {
            Text("Empty Container")
        } else {
            DrinkMakerContainerContentLivePreviewView(steps: $data.historySteps)
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
        IngredientAmountUnitSelectionView(ingredients: data.historyIngredients) { ingredient, unit, amount in
            withAnimation {
                let step = Step(context: viewContext)
                step.name = DrinkMakerFormatter.format(ingredient, unit, amount)
                add(step)
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
