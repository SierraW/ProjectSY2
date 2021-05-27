//
//  ProductContainerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct ProductContainerListView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ProductContainer.name, ascending: true)],
                  animation: .default)
    var productContainers: FetchedResults<ProductContainer>
    var selected: ((ProductContainer) -> Void)?
    @State var isShowingPCAddtionView = false
    @State var isFailedToDelete = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Product Containers")
                        .font(.title)
                    Spacer()
                    Button("Add") {
                        isShowingPCAddtionView = true
                    }
                }
                pcList
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isShowingPCAddtionView, content: {
            ProductContainerAdditionView().environment(\.managedObjectContext, viewContext)
        })
        .alert(isPresented: $isFailedToDelete, content: {
            Alert(title: Text("Delete failed."))
        })
    }
    
    @ViewBuilder
    var pcList: some View {
        if productContainers.isEmpty {
            HStack {
                Text("Empty")
                Spacer()
            }
        } else {
            List {
                ForEach(productContainers) { pc in
                    if selected == nil {
                        Text(pc.name ?? "Error item")
                    } else {
                        Button(pc.name ?? "Error item") {
                            selected!(pc)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteProductContainer(_ indexSet: IndexSet) {
        for index in indexSet {
            viewContext.delete(productContainers[index])
        }
        do {
            try viewContext.save()
        } catch {
            isFailedToDelete = true
        }
    }
}

struct ProductContainerListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContainerListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
