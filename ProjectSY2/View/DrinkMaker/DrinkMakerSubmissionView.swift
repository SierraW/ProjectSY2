//
//  DrinkMakerSubmissionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI

struct DrinkMakerSubmissionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var drinkMakerData: DrinkMakerData
    @EnvironmentObject var landingViewData: LandingViewData
    @State var warningSaveFailed = false
    
    var body: some View {
        Section {
            if drinkMakerData.mode == .Creator {
                versionCreator
            } else if drinkMakerData.mode == .Exam {
                examResult
            } else {
                
            }
        }
        .alert(isPresented: $warningSaveFailed, content: {
            Alert(title: Text("Save failed"))
        })
    }
    
    @ViewBuilder
    var versionCreator: some View {
        VStack {
            HStack {
                Text(drinkMakerData.productName)
                    .font(.title)
            }
            List {
                ForEach(drinkMakerData.steps) { step in
                    if let name = step.name {
                        Text(name)
                    } else {
                        DrinkMakerStepsView(isShowingDetail: true)
                            .environmentObject(DrinkMakerStepsData(drinkMakerData.histories[Int(step.index)]))
                    }
                }
            }
            VStack {
                Button(action: {
                    landingViewData.controller.creatorMode()
                }, label: {
                    SubmitButtonView(title: "Start again")
                })
            }
        }
    }
    
    @ViewBuilder
    var versionSelector: some View {
        Text("")
    }
    
    @ViewBuilder
    var examResult: some View {
        VStack {
            HStack {
                Text("Exam Result")
                    .font(.title)
            }
            HStack {
                
            }
        }
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            warningSaveFailed = true
        }
    }
}

struct DrinkMakerSubmissionView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerSubmissionView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(DrinkMakerData())
            .environmentObject(LandingViewData())
    }
}
