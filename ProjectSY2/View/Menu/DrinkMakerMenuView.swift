//
//  DrinkMakerMenuView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI

struct DrinkMakerMenuView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Series.name, ascending: true)],
                  animation: .default)
    var serieses: FetchedResults<Series>
    @EnvironmentObject var landingViewData: LandingViewData
    var controller: DrinkMakerController {
        landingViewData.controller
    }
    @State var warningNotEnoughVersions = false
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("DrinkMarker™")
                    .font(.title)
                Text("Simulator Menu")
                Spacer()
            }
            .padding()
            Button(action: {
                controller.creatorMode()
                landingViewData.isShowingMainMenu = false
            }, label: {
                SubmitButtonView(title: "Creator", font: 23, backgroundColor: Color.black)
            })
            Spacer()
            Button(action: {
                controller.pracitcePreparingMode()
                landingViewData.isShowingMainMenu = false
            }, label: {
                SubmitButtonView(title: "Practice", font: 23, backgroundColor: Color.black)
            })
            Spacer()
            Button(action: {
                if controller.randomMode(serieses: Array(serieses)) {
                    landingViewData.isShowingMainMenu = false
                } else {
                    warningNotEnoughVersions = true
                }
            }, label: {
                SubmitButtonView(title: "Random Practice", font: 23, backgroundColor: Color.black)
            })
            Spacer()
            Button(action: {
                if controller.ExamMode(isRandomized: true, serieses: Array(serieses)) {
                    landingViewData.isShowingMainMenu = false
                } else {
                    warningNotEnoughVersions = true
                }
            }, label: {
                SubmitButtonView(title: "Exam", font: 25, backgroundColor: Color.black)
            })
        }
        .alert(isPresented: $warningNotEnoughVersions, content: {
            Alert(title: Text("Not enough product in database"))
        })
    }
}

struct DrinkMakerMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerMenuView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(LandingViewData())
    }
}
