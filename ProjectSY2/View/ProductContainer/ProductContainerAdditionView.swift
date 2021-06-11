//
//  ProductContainerAdditionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI
import Combine

class ProductContainerAdditionData: ObservableObject {
    @Published var productContainer: ProductContainer?
    @Published var name: String
    @Published var operations: [Operation]
    @Published var ingredients: [Ingredient]
    @Published var emptyTitleWarning = false
    @Published var isShowingPCAddtionView = false
    
    init(_ productContainer: ProductContainer?) {
        self.name = "New Product Container"
        self.productContainer = productContainer
        self.operations = []
        self.ingredients = []
        
        if let pc = productContainer {
            if let name = pc.name {
                self.name = name
            }
            if let operations = pc.operations {
                self.operations = Array(operations as! Set<Operation>)
            }
            if let ingredients = pc.ingredients {
                self.ingredients = Array(ingredients as! Set<Ingredient>)
            }
        }
    }
    
    func set(_ productContainer: ProductContainer?) {
        name = ""
        operations = []
        ingredients = []
        emptyTitleWarning = false
        isShowingPCAddtionView = true
        self.productContainer = productContainer
        if let pc = productContainer {
            if let name = pc.name {
                self.name = name
            }
            if let opes = pc.operations {
                operations = Array(opes as! Set<Operation>)
            }
            if let ings = pc.ingredients {
                ingredients = Array(ings as! Set<Ingredient>)
            }
        } else {
            self.productContainer = nil
        }
    }
    
    func add(_ ingredient: Ingredient) {
        if let pc = productContainer {
            if pc.ingredients?.contains(ingredient) ?? false {
                if let index = ingredients.firstIndex(of: ingredient) {
                    ingredients.remove(at: index)
                }
                pc.removeFromIngredients(ingredient)
            } else {
                ingredients.append(ingredient)
                pc.addToIngredients(ingredient)
            }
        }
    }
    
    func add(_ operation: Operation) {
        if let pc = productContainer {
            if pc.operations?.contains(operation) ?? false {
                if let index = operations.firstIndex(of: operation) {
                    operations.remove(at: index)
                }
                pc.removeFromOperations(operation)
            } else {
                operations.append(operation)
                pc.addToOperations(operation)
            }
        }
    }
}

struct ProductContainerAdditionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var data: ProductContainerAdditionData
    var editDisabled = false
    @State var isShowingIngredientSelectionView = false
    @State var isShowingOperationSelectionView = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Product Container")
                    Spacer()
                }
                HStack {
                    Image(systemName: "pencil")
                    TextField("Name of the Product Container", text: $data.name, onEditingChanged: {_ in }) {
                        submit()
                    }
                        .font(.title2)
                    .border(data.emptyTitleWarning ? Color.red : Color.clear, width: 2)
                }
                assignedActionSection
            }
            .padding()
        }
        .sheet(isPresented: $isShowingIngredientSelectionView, content: {
            IngredientListView(selectedIngredients: $data.ingredients) { ig in
                data.add(ig)
                save()
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(IngredientData())
        })
        .sheet(isPresented: $isShowingOperationSelectionView, content: {
            OperationListView(selectedOperations: $data.operations) { op in
                data.add(op)
                save()
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(OperationData())
        })
        .alert(isPresented: $data.emptyTitleWarning, content: {
            Alert(title: Text("Product Container name cannot be empty"))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if data.productContainer == nil {
            Text("New Product Container")
                .font(.title)
        } else {
            Text(data.productContainer!.name ?? "Error item")
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
        } else {
            List {
                ForEach (data.ingredients) { ing in
                    Text(ing.name ?? "Error item")
                }
                .onDelete(perform: { indexSet in
                    removeIngredients(atOffsets: indexSet)
                })
            }
        }
    }
    
    @ViewBuilder
    var assignedActionSection: some View {
        if data.productContainer == nil {
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    Text("Not available")
                    Spacer()
                }
                Spacer()
            }
        } else {
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
    }
    
    private func removeIngredients(atOffsets indexSet: IndexSet) {
        if let productContainer = data.productContainer {
            for index in indexSet {
                let ingredient = data.ingredients[index]
                productContainer.removeFromIngredients(ingredient)
            }
        }
        data.ingredients.remove(atOffsets: indexSet)
        save()
    }
    
    private func removeOperations(atOffsets indexSet: IndexSet) {
        if let productContainer = data.productContainer {
            for index in indexSet {
                let operation = data.operations[index]
                productContainer.removeFromOperations(operation)
            }
        }
        data.operations.remove(atOffsets: indexSet)
        save()
    }
    
    private func submit() {
        withAnimation {
            if data.name == "" {
                data.emptyTitleWarning = true
                return
            }
            if data.productContainer == nil {
                let newItem = ProductContainer(context: viewContext)
                newItem.name = data.name
                data.set(newItem)
            } else if data.name != "" {
                data.productContainer!.name = data.name
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

struct ProductContainerAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContainerAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(ProductContainerAdditionData(nil))
    }
}
