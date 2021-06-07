//
//  IngredientAdditionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI
import Combine

class IngredientData: ObservableObject {
    @Published var ingredient: Ingredient? = nil
    @Published var name = ""
    @Published var isShowingIngredientDetailView = false
    
    func set(_ ingredient: Ingredient?) {
        self.name = ""
        self.ingredient = ingredient
        self.isShowingIngredientDetailView = true
    }
}

struct IngredientAdditionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var data: IngredientData
    @State var emptyTitleWarning = false
    @State var modifyWarning = false
    @State var isSelectingContainer = false
    @State var isSelectingOperation = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Ingredient")
                    Spacer()
                }
                HStack {
                    Image(systemName: "pencil")
                    TextField("Name of the ingredient", text: $data.name, onEditingChanged: {_ in }) {
                        submit()
                    }
                        .font(.title2)
                        .border(emptyTitleWarning ? Color.red : Color.clear, width: 2)
                }
                HStack {
                    Text("Unit and Amount Settings")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                auView
            }
            .padding()
        }
        .alert(isPresented: $emptyTitleWarning, content: {
            Alert(title: Text("Name of the ingredient cannot be empty."))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if data.ingredient == nil {
            Text("New Ingredient")
                .font(.title)
        } else {
            Text(data.ingredient!.name ?? "Unnamed")
                .font(.title)
        }
    }
    
    @ViewBuilder
    var auView: some View {
        VStack {
            if data.ingredient == nil {
                Text("Not available")
            } else {
                AmountAndUnitSelectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(AmountAndUnitSelectionData(data.ingredient!))
            }
        }
        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center)
    }
    
    private func submit() {
        withAnimation {
            if data.ingredient == nil {
                if data.name != "" {
                    let newItem = Ingredient(context: viewContext)
                    newItem.name = data.name
                } else {
                    emptyTitleWarning = true
                    return
                }
            } else if data.name != "" {
                data.ingredient!.name = data.name
            }
            save()
        }
    }
    
    private func save() {
        do {
            try viewContext.save()
            data.isShowingIngredientDetailView = false
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct IngredientAdditionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientAdditionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(IngredientData())
    }
}
