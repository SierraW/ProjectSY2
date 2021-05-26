//
//  IngredientAdditionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct IngredientAdditionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var ingredient: Ingredient?
    @State var name = ""
    @State var containers: [Container] = []
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
                    Text("Assigned Containers")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Add") {
                        // add contianer
                    }
                }
                containerList
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 300, idealHeight: 900, maxHeight:.infinity, alignment: .topLeading)
                HStack {
                    Text("Assigned Operations")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Add") {
                        // add operations
                    }
                }
                containerList
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 200, idealHeight: 500, maxHeight:.none, alignment: .topLeading)
            }
            .padding()
            Button(action: {
                verifyFields()
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .alert(isPresented: $emptyTitleWarning, content: {
            Alert(title: Text("Name cannot be empty."))
        })
        .alert(isPresented: $modifyWarning, content: {
            Alert(title: Text("Changes about to apply"), message: Text("Name of the ingredient: \(name), and the containers above."), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                self.modifyWarning = false
                self.editIngredient()
            }))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if ingredient == nil {
            Text("New Ingredient")
                .font(.title)
        } else {
            Text(ingredient!.name ?? "Unnamed")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var containerList: some View {
        if containers.isEmpty {
            HStack {
                Text("No assigned container")
                Spacer()
            }
        } else {
            List {
                ForEach(containers) { con in
                    Text(con.name ?? "Error item")
                }
                .onDelete(perform: { indexSet in
                    if ingredient != nil {
                        for index in indexSet {
                            ingredient!.removeFromContainers(containers[index])
                        }
                    }
                    containers.remove(atOffsets: indexSet)
                })
            }
        }
    }
    
    @ViewBuilder
    var operationList: some View {
        if operations.isEmpty {
            HStack {
                Text("No assigned operation")
            }
        } else {
            List {
                ForEach(operations) { ope in
                    Text(ope.name ?? "Error item")
                }
                .onDelete(perform: { indexSet in
                    if let ingredient = ingredient {
                        for index in indexSet {
                            ingredient.removeFromOperations(operations[index])
                        }
                    }
                    operations.remove(atOffsets: indexSet)
                })
            }
        }
    }
    
    private func verifyFields() {
        if name == "" && ingredient == nil {
            emptyTitleWarning = true
            return
        }
        modifyWarning = true
    }
    
    private func editIngredient() {
        if ingredient == nil {
            withAnimation {
                let newItem = Ingredient(context: viewContext)
                newItem.name = name
                for container in containers {
                    newItem.addToContainers(container)
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
            
        } else {
            
        }
    }
}

struct IngredientAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
