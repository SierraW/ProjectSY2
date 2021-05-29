//
//  DrinkMakerContainerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-27.
//

import SwiftUI
import Combine

class DrinkMakerContainerData: ObservableObject {
    var container: Container
    @Published var steps: [Step]
    
    init(_ container: Container) {
        self.container = container
        self.steps = []
        if let steps = container.steps {
            self.steps = Array(steps as! Set<Step>)
        }
    }
}

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
            Divider()
            containerStepList
            selectionMenu
            mainInteractingSection
        }
        .padding()
    }
    
    @ViewBuilder
    var containerStepList: some View {
        Text("List")
    }
    
    @ViewBuilder
    var selectionMenu: some View {
        HStack {
            Text("Ingredients")
            Divider()
            Text("Operations")
        }
    }
    
    @ViewBuilder
    var ingredientList: some View {
        Text("I L")
    }
    
    @ViewBuilder
    var mainInteractingSection: some View {
        Text("Interacting Area")
    }
    
}

struct DrinkMakerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerContainerView(name: "Gugubird", steps: [])
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
