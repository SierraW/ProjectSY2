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
    @Published var name = ""
    @Published var operations: [Operation] = []
    
    func set(_ container: Container?) {
        if let container = container, let operations = container.operations {
            self.operations = Array(operations as! Set<Operation>)
            self.name = ""
        } else {
            self.operations = []
            self.name = ""
        }
        self.container = container
        self.isShowingContainerDetailView = true
    }
}

struct ContainerAdditionView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @EnvironmentObject var containerData: ContainerData
    @State var emptyTitleWarning = false
    @State var modifyWarning = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    title
                    Spacer()
                }
                TextField("Edit name...", text: $containerData.name)
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
                verifyFields()
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .alert(isPresented: $modifyWarning, content: {
            Alert(title: Text("Changes about to apply"), message: Text("Name of the container: \(containerData.name), and the operations listed above."), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                self.modifyWarning = false
                self.submit()
            }))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if containerData.container == nil {
            Text("New Container")
                .font(.title)
        } else {
            Text(containerData.container!.name ?? "Error item")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var operationList: some View {
        if containerData.operations.isEmpty {
            HStack {
                Text("No assigned operation")
                Spacer()
            }
        } else {
            List {
                ForEach (containerData.operations) { ope in
                    Text(ope.name ?? "Error item")
                }
            }
        }
    }
    
    private func verifyFields() {
        if containerData.name == "" && containerData.container == nil {
            emptyTitleWarning = true
            return
        }
        modifyWarning = true
    }
    
    private func submit() {
        withAnimation {
            if containerData.container == nil {
                let newItem = Container(context: viewContext)
                newItem.name = containerData.name
                newItem.steps = Set<Step>() as NSSet
                newItem.operations = Set<Operation>() as NSSet
                for op in containerData.operations {
                    newItem.addToOperations(op)
                }
            } else if containerData.name != "" {
                containerData.container!.name = containerData.name
            }
            do {
                try viewContext.save()
                containerData.isShowingContainerDetailView = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
