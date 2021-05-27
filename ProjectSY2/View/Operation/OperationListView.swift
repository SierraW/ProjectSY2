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
    var isDeleteDisabled = false
    var selected: ((Operation) -> Void)?
    @State var isDeleteFailed = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Operation")
                        .font(.title)
                    Spacer()
                    Button("Add") {
                        operationData.set(nil)
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
        .alert(isPresented: $isDeleteFailed, content: {
            Alert(title: Text("Delete failed."))
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
                    if selected == nil {
                        Button(oper.name ?? "Error item") {
                            operationData.set(oper)
                        }
                    } else {
                        Button(oper.name ?? "Error item") {
                            selected!(oper)
                        }
                    }
                }
                .onDelete(perform: deleteContainers(_:))
                .deleteDisabled(isDeleteDisabled)
            }
        }
    }
    
    private func deleteContainers(_ indexSet: IndexSet) {
        for index in indexSet {
            viewContext.delete(operations[index])
        }
        do {
            try viewContext.save()
        } catch {
            isDeleteFailed = true
        }
    }
}

struct OperationListView_Previews: PreviewProvider {
    static var previews: some View {
        OperationListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(OperationData())
    }
}
