//
//  OperationEditingView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

class OperationData: ObservableObject {
    @Published var operation: Operation? = nil
    @Published var isShowingContainerDetailView = false
    @Published var name = ""
    
    func set(_ operation: Operation?) {
        self.name = ""
        self.operation = operation
        self.isShowingContainerDetailView = true
    }
}

struct OperationEditingView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var operationData: OperationData
    @State var emptyTitleWarning = false
    @State var modifyWarning = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    title
                    Spacer()
                }
                TextField("Edit name...", text: $operationData.name)
                    .font(.title2)
                    .border(emptyTitleWarning ? Color.red : Color.clear, width: 2)
                Spacer()
            }
            .padding()
            Button(action: {
                verifyFields()
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .alert(isPresented: $modifyWarning, content: {
            Alert(title: Text("Changes about to apply"), message: Text("Name of the operation: \(operationData.name), and the operations listed above."), primaryButton: .cancel(), secondaryButton: .default(Text("Ok"), action: {
                self.modifyWarning = false
                self.submit()
            }))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if operationData.operation == nil {
            Text("New Operation")
                .font(.title)
        } else {
            Text(operationData.operation!.name ?? "Error item")
                .font(.title)
        }
    }
    
    private func verifyFields() {
        if operationData.name == "" && operationData.operation == nil {
            emptyTitleWarning = true
            return
        }
        modifyWarning = true
    }
    
    private func submit() {
        withAnimation {
            if operationData.operation == nil {
                let newItem = Operation(context: viewContext)
                newItem.name = operationData.name
            } else if operationData.name != "" {
                operationData.operation!.name = operationData.name
            }
            do {
                try viewContext.save()
                operationData.isShowingContainerDetailView = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct OperationEditingView_Previews: PreviewProvider {
    static var previews: some View {
        OperationEditingView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(OperationData())
    }
}
