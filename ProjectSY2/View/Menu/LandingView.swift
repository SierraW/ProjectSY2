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
    
    init() {
        drinkMakerData = DrinkMakerData()
        controller = DrinkMakerController(drinkMakerData)
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
        
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
            .environmentObject(LandingViewData())
    }
}
