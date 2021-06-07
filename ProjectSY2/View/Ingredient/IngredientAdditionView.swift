//
//  IngredientAdditionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI
import Combine

class IngredientData: ObservableObject {
    @Published var ingredient: Ingredient? = nil
    @Published var name = ""
    @Published var containers: [Container] = []
    @Published var operations: [Operation] = []
    @Published var isShowingIngredientDetailView = false
    
    func set(_ ingredient: Ingredient?) {
        self.name = ""
        self.containers = []
        self.operations = []
        if let ingredient = ingredient {
            if let containers = ingredient.containers {
                self.containers = Array(containers as! Set<Container>)
            }
            if let operations = ingredient.operations {
                self.operations = Array(operations as! Set<Operation>)
            }
        }
        self.ingredient = ingredient
        self.isShowingIngredientDetailView = true
    }
}

struct IngredientAdditionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var ingredientData: IngredientData
    @State var emptyTitleWarning = false
    @State var modifyWarning = false
    @State var isSelectingContainer = false
    @State var isSelectingOperation = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    title
                    Spacer()
                }
                TextField("New name...", text: $ingredientData.name)
                    .font(.title2)
                    .border(emptyTitleWarning ? Color.red : Color.clear, width: 2)
                HStack {
                    Text("Unit and Amount Settings")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                auView
            }
            .padding()
            Button(action: {
                verifyFields()
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .sheet(isPresented: $isSelectingOperation, content: {
            OperationListView(showTitle: true) { operation in
                isSelectingOperation = false
                self.addOperation(operation)
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(OperationData())
        })
        .sheet(isPresented: $isSelectingContainer, content: {
            ContainerListView(isDeleteDisabled: true) { container in
                isSelectingContainer = false
                self.addContainer(container)
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(ContainerData())
        })
        .alert(isPresented: $emptyTitleWarning, content: {
            Alert(title: Text("Name cannot be empty."))
        })
        .alert(isPresented: $modifyWarning, content: {
            Alert(title: Text("Changes about to apply"), message: Text("Name of the ingredient: \(ingredientData.name), and the containers above."), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                self.modifyWarning = false
                self.submit()
            }))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if ingredientData.ingredient == nil {
            Text("New Ingredient")
                .font(.title)
        } else {
            Text(ingredientData.ingredient!.name ?? "Unnamed")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var auView: some View {
        VStack {
            if ingredientData.ingredient == nil {
                Text("Not available")
            } else {
                AmountAndUnitSelectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(AmountAndUnitSelectionData(ingredientData.ingredient!))
            }
        }
        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center)
    }
    
    private func addContainer(_ container: Container) {
        ingredientData.containers.append(container)
        ingredientData.ingredient?.addToContainers(container)
    }
    
    private func addOperation(_ operation: Operation) {
        ingredientData.operations.append(operation)
        ingredientData.ingredient?.addToOperations(operation)
    }
    
    private func deleteContainer(_ indexSet: IndexSet) {
        if ingredientData.ingredient != nil {
            for index in indexSet {
                let container = ingredientData.containers[index]
                ingredientData.ingredient!.removeFromContainers(container)
            }
        }
        ingredientData.containers.remove(atOffsets: indexSet)
    }
    
    private func deleteOperation(_ indexSet: IndexSet) {
        if ingredientData.ingredient != nil {
            for index in indexSet {
                let operation = ingredientData.operations[index]
                ingredientData.ingredient!.removeFromOperations(operation)
            }
        }
        ingredientData.operations.remove(atOffsets: indexSet)
    }
    
    private func verifyFields() {
        if ingredientData.name == "" && ingredientData.ingredient == nil {
            emptyTitleWarning = true
            return
        }
        modifyWarning = true
    }
    
    private func submit() {
        withAnimation {
            if ingredientData.ingredient == nil {
                let newItem = Ingredient(context: viewContext)
                newItem.name = ingredientData.name
                for container in ingredientData.containers {
                    newItem.addToContainers(container)
                }
                for operation in ingredientData.operations {
                    newItem.addToOperations(operation)
                }
            } else if ingredientData.name != "" {
                ingredientData.ingredient!.name = ingredientData.name
            }
            do {
                try viewContext.save()
                ingredientData.isShowingIngredientDetailView = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct IngredientAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(IngredientData())
    }
}
