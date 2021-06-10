//
//  DrinkMakerContainerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-27.
//

import SwiftUI
import Combine

class DrinkMakerContainerData: ObservableObject {
    var history: History?
    @Published var steps: [Step]
    @Published var ingredients: [Ingredient]
    @Published var operations: [Operation]
    @Published var isSelectedIngredient = false
    @Published var ingredientNotEmpty = false
    @Published var operationNotEmpty = false
    @Published var selectedIngredient: Ingredient? = nil
    @Published var selectedOperation: Operation? = nil
    
    init(_ history: History?) {
        self.history = history
        self.steps = []
        self.ingredients = []
        self.operations = []
        if let steps = history?.steps {
            self.steps = Array(steps as! Set<Step>)
        }
        if let operations = history?.container?.operations, operations.count > 0 {
            operationNotEmpty = true
            self.operations = Array(operations as! Set<Operation>)
        }
        if let ingredients = history?.container?.ingredients, ingredients.count > 0 {
            ingredientNotEmpty = true
            isSelectedIngredient = true
            self.ingredients = Array(ingredients as! Set<Ingredient>)
        }
    }
    
    func setFocus() {
        if ingredientNotEmpty && operationNotEmpty {
            isSelectedIngredient.toggle()
        }
    }
    
    func add(_ step: Step) {
        if let history = history {
            history.addToSteps(step)
        }
        steps.append(step)
    }
}

struct DrinkMakerContainerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var drinkMakerData: DrinkMakerData
    @EnvironmentObject var drinkMakerContainerData: DrinkMakerContainerData
    var showActionField = true
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Container")
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
    }
    
    @ViewBuilder
    var containerStepList: some View {
        if drinkMakerContainerData.steps.isEmpty {
            Text("Empty Container")
        } else {
            List {
                ForEach(drinkMakerContainerData.steps) { step in
                    Text(step.name ?? "Error item")
                }
            }
        }
    }
    
    @ViewBuilder
    var selectionMenu: some View {
        HStack {
            Spacer()
            if drinkMakerContainerData.ingredientNotEmpty {
                Button(action: {
                    drinkMakerContainerData.setFocus()
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
            if drinkMakerContainerData.operationNotEmpty {
                Button(action: {
                    drinkMakerContainerData.setFocus()
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
            if drinkMakerContainerData.selectedIngredient == nil {
                List {
                    ForEach(drinkMakerContainerData.ingredients) { ingredient in
                        Button(ingredient.name ?? "Error item") {
                            drinkMakerContainerData.selectedIngredient = ingredient
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .gesture(TapGesture().onEnded({ _ in
                                drinkMakerContainerData.selectedIngredient = nil
                            }))
                        Text(drinkMakerContainerData.selectedIngredient!.name ?? "Error item")
                        Spacer()
                    }
                    AmountAndUnitSelectionView() { unit, amount in
                        let step = Step(context: viewContext)
                        step.name = "\(amount.name ?? "Error item")\(unit.name ?? "Error item") \(drinkMakerContainerData.selectedIngredient?.name ?? "Error item")"
                        drinkMakerContainerData.add(step)
                    }
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(AmountAndUnitSelectionData(drinkMakerContainerData.selectedIngredient!))
                }
            }
            
        }
    }
    
    @ViewBuilder
    var operationAction: some View {
        List {
            ForEach(drinkMakerContainerData.operations) { operation in
                Button(action: {
                    let step = Step(context: viewContext)
                    step.name = operation.name
                    drinkMakerContainerData.add(step)
                }, label: {
                    Text(operation.name ?? "Error item")
                })
            }
        }
    }
    
    @ViewBuilder
    var mainInteractingSection: some View {
        if drinkMakerContainerData.ingredientNotEmpty || drinkMakerContainerData.operationNotEmpty {
            if drinkMakerContainerData.isSelectedIngredient {
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
}

struct DrinkMakerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerContainerView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(DrinkMakerData())
            .environmentObject(DrinkMakerContainerData(nil))
    }
}
