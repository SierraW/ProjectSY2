//
//  ContainerListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct ContainerListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var containerData: ContainerData
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Container.name, ascending: true)],
                  animation: .default)
    var containers: FetchedResults<Container>
    var showTitle = true
    var isDeleteDisabled = false
    var selected: ((Container) -> Void)?
    @State var isDeleteFailed = false
    
    var body: some View {
        ZStack {
            VStack {
                if showTitle {
                    HStack {
                        Text("Containers")
                            .font(.title)
                        Spacer()
                        if selected == nil {
                            Button("Add") {
                                containerData.set(nil)
                            }
                        }
                    }
                }
                containerList
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $containerData.isShowingContainerDetailView, content: {
            ContainerAdditionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(containerData)
        })
        .alert(isPresented: $isDeleteFailed, content: {
            Alert(title: Text("Delete failed."))
        })
    }
    
    @ViewBuilder
    var containerList: some View {
        if containers.isEmpty {
            HStack {
                Text("Empty")
                Spacer()
            }
        } else {
            List {
                ForEach(containers) { con in
                    if selected == nil {
                        Button(con.name ?? "Error item") {
                            containerData.set(con)
                        }
                    } else {
                        Button(con.name ?? "Error item") {
                            selected!(con)
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
            viewContext.delete(containers[index])
        }
        do {
            try viewContext.save()
        } catch {
            isDeleteFailed = true
        }
    }
}

struct ContainerListView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(ContainerData())
    }
}
