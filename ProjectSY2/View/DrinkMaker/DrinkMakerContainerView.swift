//
//  DrinkMakerContainerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-27.
//

import SwiftUI

struct DrinkMakerContainerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var name: String
    @State var steps: [Step]
    
    var body: some View {
        VStack {
            HStack {
                Text("Container")
                Spacer()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var containerStepList: some View {
        Text("List")
    }
}

struct DrinkMakerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerContainerView(name: "Gugubird", steps: [])
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
