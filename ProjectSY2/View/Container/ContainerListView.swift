//
//  ContainerListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct ContainerListView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ContainerListView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
