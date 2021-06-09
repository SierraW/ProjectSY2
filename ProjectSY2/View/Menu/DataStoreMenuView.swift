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
            .padding()
            VStack(spacing: 15) {
                NavigationLink(
                    destination: ProductContainerListView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .environmentObject(ProductContainerAdditionData(nil)),
                    label: {
                        SubmitButtonView(title: "Product Container", font: 17, foregroundColor: Color.black, backgroundColor: Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    })
                NavigationLink(
                    destination: ContainerListView()
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .environmentObject(ContainerData()),
                    label: {
                        SubmitButtonView(title: "Container", font: 17, foregroundColor: Color.black, backgroundColor: Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    })
                NavigationLink(
                    destination: IngredientListView(selectedIngredients: .constant([]))
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .environmentObject(IngredientData()),
                    label: {
                        SubmitButtonView(title: "Ingredient", font: 17, foregroundColor: Color.black, backgroundColor: Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    })
                NavigationLink(
                    destination: OperationListView(selectedOperations: .constant([]))
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .environmentObject(OperationData()),
                    label: {
                        SubmitButtonView(title: "Operaion", font: 17, foregroundColor: Color.black, backgroundColor: Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    })
                NavigationLink(
                    destination: SeriesListView(isPresented: .constant(true))
                        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                        .environmentObject(ProductAndVersionData(nil)),
                    label: {
                        SubmitButtonView(title: "Version", font: 17, foregroundColor: Color.black, backgroundColor: Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                    })
            }
        }
    }
}

struct DataStoreMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DataStoreMenuView()
    }
}
