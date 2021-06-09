//
//  OperationListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct OperationListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var operationData: OperationData
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Operation.name, ascending: true)],
                  animation: .default)
    var operations: FetchedResults<Operation>
    @Binding var selectedOperations: [Operation]
    var showTitle = true
    var editDisabled = false
    var selected: ((Operation) -> Void)?
    @State var name: String = ""
    @State var editingElement: Operation?
    @State var isSaveFailed = false
    
    var body: some View {
        ZStack {
            VStack {
                if showTitle {
                    HStack {
                        Text("Operation")
                            .font(.title)
                        Spacer()
                        Button("Add") {
                            operationData.set(nil)
                        }
                    }
                }
                operationList
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $operationData.isShowingContainerDetailView, content: {
            OperationEditingView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(operationData)
        })
        .alert(isPresented: $isSaveFailed, content: {
            Alert(title: Text("Save failed."))
        })
    }
    
    @ViewBuilder
    var operationList: some View {
        if operations.isEmpty {
            HStack {
                Text("Empty")
                Spacer()
            }
        } else {
            List {
                ForEach(operations) { oper in
                    if !editDisabled, let editingElement = editingElement, editingElement == oper {
                        TextField("Operation name", text: $name) { _ in } onCommit: {
                            oper.name = name
                            set(nil)
                            save()
                        }
                    } else {
                        HStack {
                            Text(oper.name ?? "Error item")
                            Spacer()
                            if !selectedOperations.isEmpty && selectedOperationsContains(oper) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .onLongPressGesture {
                            if !editDisabled {
                                set(oper)
                            }
                        }
                        .onTapGesture {
                            if let selected = selected {
                                selected(oper)
                            } else {
                                operationData.set(oper)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteContainers(_:))
                .deleteDisabled(editDisabled)
            }
        }
    }
    
    private func selectedOperationsContains(_ operation: Operation) -> Bool {
        return selectedOperations.contains(operation)
    }
    
    private func set(_ operation: Operation?) {
        if let operation = operation {
            name = operation.name ?? ""
        }
        editingElement = operation
    }
    
    private func deleteContainers(_ indexSet: IndexSet) {
        for index in indexSet {
            viewContext.delete(operations[index])
        }
        save()
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            isSaveFailed = true
        }
    }
}

struct OperationListView_Previews: PreviewProvider {
    static var previews: some View {
        OperationListView(selectedOperations: .constant([]))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(OperationData())
    }
}
