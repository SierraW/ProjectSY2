//
//  ProductContainerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct ProductContainerListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var data: ProductContainerAdditionData
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ProductContainer.name, ascending: true)],
                  animation: .default)
    var productContainers: FetchedResults<ProductContainer>
    var selected: ((ProductContainer) -> Void)?
    @State var isFailedToDelete = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Product Containers")
                        .font(.title)
                    Spacer()
                    if selected == nil {
                        Button("Add") {
                            data.set(nil)
                        }
                    }
                }
                pcList
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $data.isShowingPCAddtionView, content: {
            ProductContainerAdditionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(data)
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
                        Button(action: {
                            data.set(pc)
                        }, label: {
                            Text(pc.name ?? "Error item")
                        })
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
            .environmentObject(ProductContainerAdditionData(nil))
    }
}
