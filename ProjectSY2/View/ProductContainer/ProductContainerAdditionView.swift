//
//  ProductContainerAdditionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct ProductContainerAdditionView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    var productContainer: ProductContainer? = nil
    @State var name = ""
    @State var operations: [Operation] = []
    @State var emptyTitleWarning = false
    @State var modifyWarning = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    title
                    Spacer()
                }
                TextField("Edit name...", text: $name)
                    .font(.title2)
                    .border(emptyTitleWarning ? Color.red : Color.clear, width: 2)
                HStack {
                    Text("Assigned Operations")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Add") {
                        // add operations
                    }
                }
                operationList
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 200, idealHeight: 500, maxHeight:.infinity, alignment: .topLeading)
            }
            .padding()
            Button(action: {
                
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .alert(isPresented: $modifyWarning, content: {
            Alert(title: Text("Changes about to apply"), message: Text("Name of the product container: \(name), and the operations listed above."), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                self.modifyWarning = false
                self.submit()
            }))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if productContainer == nil {
            Text("New Product Container")
                .font(.title)
        } else {
            Text(productContainer!.name ?? "Error item")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var operationList: some View {
        if operations.isEmpty {
            HStack {
                Text("No assigned operation")
                Spacer()
            }
        } else {
            List {
                ForEach (operations) { ope in
                    Text(ope.name ?? "Error item")
                }
            }
        }
    }
    
    private func verifyFields() {
        if name == "" && productContainer == nil {
            emptyTitleWarning = true
            return
        }
        modifyWarning = true
    }
    
    private func submit() {
        withAnimation {
            if productContainer == nil {
                let newItem = ProductContainer(context: viewContext)
                newItem.name = name
                for op in operations {
                    newItem.addToOperations(op)
                }
            }
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
}

struct ProductContainerAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContainerAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
