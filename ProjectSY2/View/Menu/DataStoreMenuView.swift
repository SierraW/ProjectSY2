//
//  DataStoreMenuView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI

struct DataStoreMenuView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Data Store Management")
                    .font(.title2)
                Spacer()
            }
            NavigationLink(
                destination: ProductContainerListView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(ProductContainerAdditionData(nil)),
                label: {
                    Text("Product Container")
                })
            NavigationLink(
                destination: ContainerListView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(ContainerData()),
                label: {
                    Text("Container")
                })
            NavigationLink(
                destination: IngredientListView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(IngredientData()),
                label: {
                    Text("Ingredient")
                })
            NavigationLink(
                destination: OperationListView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(OperationData()),
                label: {
                    Text("Operaion")
                })
            NavigationLink(
                destination: SeriesListView(isPresented: .constant(true))
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(ProductAndVersionData(nil)),
                label: {
                    Text("Version")
                })
        }
        .padding()
    }
}

struct DataStoreMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DataStoreMenuView()
    }
}
