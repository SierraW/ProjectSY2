//
//  DrinkMakerLoadingView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI

struct DrinkMakerLoadingView: View {
    @EnvironmentObject var drinkMakerData: DrinkMakerData
    let controller: DrinkMakerController
    
    var body: some View {
        if drinkMakerData.mode == .Practice && drinkMakerData.question == nil {
            VStack {
                Text("Please select a product")
                SeriesListView(isPresented: $drinkMakerData.isLoading) { version in
                    controller.practiceMode(version: version)
                }
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(ProductAndVersionData(nil))
            }
        } else {
            HStack {
                Text("DrinkMaker loading...")
            }
        }
    }
}

