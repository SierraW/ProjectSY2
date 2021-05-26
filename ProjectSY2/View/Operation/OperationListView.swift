//
//  OperationListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct OperationListView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct OperationListView_Previews: PreviewProvider {
    static var previews: some View {
        OperationListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
