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
    @State var enableProductName = false
    @State var productName = ""
    @State var containerName = ""
    @State var operations: [Operation] = []
    
    var body: some View {
        VStack {
            title
        }
        .padding()
    }
    
    @ViewBuilder
    var title: some View {
        if productContainer == nil {
            Text("New Product Container")
                .font(.title)
        } else {
            Text(productContainer!.containerName ?? "Error item")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var operationsList: some View {
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
}

struct ProductContainerAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        ProductContainerAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
