//
//  OperationListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct OperationListView: View {
    @Environment(\.managedObjectContext) var viewContext
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
                            add()
                        }
                    }
                }
                operationList
                Spacer()
            }
            .padding()
        }
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
                        HStack {
                            Image(systemName: "pencil")
                            TextField("Operation name", text: $name) { _ in } onCommit: {
                                oper.name = name
                                set(nil)
                                save()
                            }
                            .frame(width: 300, height: 40, alignment: .center)
                        }
                    } else {
                        HStack {
                            Text(oper.name ?? "Error item")
                                .frame(width: 300, height: 40, alignment: .leading)
                            Spacer()
                            if !selectedOperations.isEmpty && selectedOperationsContains(oper) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .onTapGesture {
                            if let selected = selected {
                                selected(oper)
                            }
                        }
                        .onLongPressGesture {
                            if !editDisabled {
                                set(oper)
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
        withAnimation {
            if let operation = operation {
                name = operation.name ?? ""
            }
            editingElement = operation
        }
    }
    
    private func add() {
        withAnimation {
            let newOperation = Operation(context: viewContext)
            newOperation.name = "NewOperation"
            selectedOperations.append(newOperation)
            set(newOperation)
        }
    }
    
    private func submit(_ operation: Operation) {
        if name == "" {
            set(nil)
            return
        }
        operation.name = name
        set(nil)
        save()
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
