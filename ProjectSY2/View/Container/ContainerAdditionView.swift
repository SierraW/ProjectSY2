//
//  ContainerAdditionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI
import Combine

class ContainerData: ObservableObject {
    @Published var container: Container? = nil
    @Published var isShowingContainerDetailView = false
    @Published var selectedIngredient: Ingredient? = nil
    @Published var name = ""
    @Published var operations: [Operation] = []
    @Published var ingredients: [Ingredient] = []
    
    func set(_ container: Container?) {
        self.operations = []
        self.ingredients = []
        self.name = ""
        
        if let container = container {
            if let operations = container.operations {
                self.operations = Array(operations as! Set<Operation>)
            }
            if let ingredients = container.ingredients {
                self.ingredients = Array(ingredients as! Set<Ingredient>)
            }
        }
        self.container = container
        self.isShowingContainerDetailView = true
    }
    
    func add(_ ingredient: Ingredient) {
        if let container = container {
            container.addToIngredients(ingredient)
            ingredients.append(ingredient)
        }
    }
    
    func add(_ operation: Operation) {
        if let container = container {
            container.addToOperations(operation)
            operations.append(operation)
        }
    }
}

struct ContainerAdditionView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var data: ContainerData
    @State var emptyTitleWarning = false
    @State var isShowingIngredientSelectionView = false
    @State var isShowingOperationSelectionView = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Container")
                    Spacer()
                }
                HStack {
                    Image(systemName: "pencil")
                    TextField("Name of the Container", text: $data.name, onEditingChanged: {_ in }) {
                        submit()
                    }
                        .font(.title2)
                    .border(emptyTitleWarning ? Color.red : Color.clear, width: 2)
                }
                HStack {
                    Text("Assigned Ingredients")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Add") {
                        isShowingIngredientSelectionView = true
                    }
                }
                ingredientList
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 200, idealHeight: 500, maxHeight:.infinity, alignment: .topLeading)
                HStack {
                    Text("Assigned Operations")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Add") {
                        isShowingOperationSelectionView = true
                    }
                }
                operationList
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 200, idealHeight: 500, maxHeight: 500, alignment: .topLeading)
            }
            .padding()
        }
        .sheet(isPresented: $isShowingIngredientSelectionView, content: {
            IngredientListView() { ig in
                data.add(ig)
                isShowingIngredientSelectionView = false
                save()
            }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(IngredientData())
        })
        .sheet(isPresented: $isShowingOperationSelectionView, content: {
            OperationListView() { op in
                data.add(op)
                isShowingOperationSelectionView = false
                save()
            }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(OperationData())
        })
        .alert(isPresented: $emptyTitleWarning, content: {
            Alert(title: Text("Name of the container cannot be empty"))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if data.container == nil {
            Text("New Container")
                .font(.title)
        } else {
            Text(data.container!.name ?? "Error item")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var operationList: some View {
        if data.operations.isEmpty {
            HStack {
                Text("No assigned operation")
                Spacer()
            }
        } else {
            List {
                ForEach (data.operations) { ope in
                    Text(ope.name ?? "Error item")
                }
                .onDelete(perform: { indexSet in
                    removeOperations(atOffsets: indexSet)
                })
            }
        }
    }
    
    @ViewBuilder
    var ingredientList: some View {
        if data.ingredients.isEmpty {
            HStack {
                Text("No assigned ingredient")
                Spacer()
            }
        } else if data.selectedIngredient == nil {
            List {
                ForEach (data.ingredients) { ing in
                    Button(ing.name ?? "Error item") {
                        data.selectedIngredient = ing
                    }
                }
                .onDelete(perform: { indexSet in
                    removeIngredients(atOffsets: indexSet)
                })
            }
        } else {
            VStack {
                HStack {
                    Button(action: {
                        data.selectedIngredient = nil
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.blue)
                            Text(data.selectedIngredient?.name ?? "Error item")
                        }
                    })
                    Spacer()
                }
                .padding(.top, 5)
                AmountAndUnitSelectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(AmountAndUnitSelectionData(data.selectedIngredient!))
            }
        }
    }
    
    private func removeIngredients(atOffsets indexSet: IndexSet) {
        if let container = data.container {
            for index in indexSet {
                let ingredient = data.ingredients[index]
                container.removeFromIngredients(ingredient)
            }
        }
        data.ingredients.remove(atOffsets: indexSet)
        save()
    }
    
    private func removeOperations(atOffsets indexSet: IndexSet) {
        if let container = data.container {
            for index in indexSet {
                let operation = data.operations[index]
                container.removeFromOperations(operation)
            }
        }
        data.operations.remove(atOffsets: indexSet)
        save()
    }
    
    private func submit() {
        withAnimation {
            if data.name == "" {
                emptyTitleWarning = true
                return
            }
            if data.container == nil {
                let newItem = Container(context: viewContext)
                newItem.name = data.name
                newItem.operations = Set<Operation>() as NSSet
                for op in data.operations {
                    newItem.addToOperations(op)
                }
            } else if data.name != "" {
                data.container!.name = data.name
            }
            save()
        }
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ContainerAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(ContainerData())
    }
}
