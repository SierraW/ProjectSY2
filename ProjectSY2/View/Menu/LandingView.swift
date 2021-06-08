//
//  LandingView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI
import Combine

class LandingViewData: ObservableObject {
    @Published var isShowingMainMenu = true
    var drinkMakerData: DrinkMakerData
    let controller: DrinkMakerController
    @Published var warning: DrinkMakerWarning?
    
    init() {
        drinkMakerData = DrinkMakerData()
        controller = DrinkMakerController(drinkMakerData)
    }
    
    func back() {
        isShowingMainMenu = true
    }
    
    func back(with warning: DrinkMakerWarning) {
        showWarning(warning)
        isShowingMainMenu = true
    }
    
    func showWarning(_ warning: DrinkMakerWarning) {
        self.warning = warning
    }
}

struct LandingView: View {
    @EnvironmentObject var data: LandingViewData
    
    var body: some View {
        Section {
            if data.isShowingMainMenu {
                NavigationView {
                    VStack {
                        Text("ProjectSY2 Ver0.1")
                        DrinkMakerMenuView()
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                            .environmentObject(data)
                        DataStoreMenuView()
                    }
                    .navigationBarHidden(true)
                }
            } else {
                DrinkMakerView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .environmentObject(data.drinkMakerData)
            }
        }
        .alert(item: $data.warning) { warning in
            Alert(title: Text(warning.message))
        }
        
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
            .environmentObject(LandingViewData())
    }
}
