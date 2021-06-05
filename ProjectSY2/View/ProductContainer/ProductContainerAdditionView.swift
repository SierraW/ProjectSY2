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
    @Published var modifyWarning = false
    @Published var isShowingPCAddtionView = false
    
    init(_ productContainer: ProductContainer?) {
        self.name = ""
        self.operations = []
        self.ingredients = []
        
        if let pc = productContainer {
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
        modifyWarning = false
        isShowingPCAddtionView = true
        if let pc = productContainer {
            self.productContainer = pc
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
            ingredients.append(ingredient)
            pc.addToIngredients(ingredient)
        }
    }
    
    func add(_ operation: Operation) {
        if let pc = productContainer {
            operations.append(operation)
            pc.addToOperations(operation)
        }
    }
}

struct ProductContainerAdditionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var data: ProductContainerAdditionData
    @State var isShowingIngredientSelectionView = false
    @State var isShowingOperationSelectionView = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    title
                    Spacer()
                }
                TextField("Edit name...", text: $data.name)
                    .font(.title2)
                    .border(data.emptyTitleWarning ? Color.red : Color.clear, width: 2)
                assignedActionSection
            }
            .padding()
            Button(action: {
                verifyFields()
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .sheet(isPresented: $isShowingIngredientSelectionView, content: {
            IngredientListView { ig in
                data.add(ig)
                isShowingIngredientSelectionView = false
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(IngredientData())
        })
        .sheet(isPresented: $isShowingOperationSelectionView, content: {
            OperationListView { op in
                data.add(op)
                isShowingOperationSelectionView = false
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(OperationData())
        })
        .alert(isPresented: $data.modifyWarning, content: {
            Alert(title: Text("Changes about to apply"), message: Text("Name of the product container: \(data.name), and the operations listed above."), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                data.modifyWarning = false
                self.submit()
            }))
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
    
    private func verifyFields() {
        if data.name == "" && data.productContainer == nil {
            data.emptyTitleWarning = true
            return
        }
        data.modifyWarning = true
    }
    
    private func submit() {
        withAnimation {
            if data.productContainer == nil {
                let newItem = ProductContainer(context: viewContext)
                newItem.name = data.name
                for op in data.operations {
                    newItem.addToOperations(op)
                }
            }
            do {
                try viewContext.save()
                data.isShowingPCAddtionView = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
