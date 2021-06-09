//
//  DrinkMakerSubmissionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI

struct DrinkMakerSubmissionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Series.name, ascending: true)],
                  animation: .default)
    var serieses: FetchedResults<Series>
    @EnvironmentObject var drinkMakerData: DrinkMakerData
    @EnvironmentObject var landingViewData: LandingViewData
    
    var body: some View {
        Section {
            if drinkMakerData.mode == .Creator {
                versionCreator
            } else if drinkMakerData.mode == .Exam {
                examResult
            } else {
                compareView
            }
        }
    }
    
    @ViewBuilder
    var compareView: some View {
        VStack {
            if let question = drinkMakerData.question {
                VStack {
                    Text(question.isCorrect ? "Correct" : "Wrong")
                        .foregroundColor(question.isCorrect ? .green : .red)
                    DrinkMakerComparisonView(from: question)
                    DrinkMakerResultCorrectionBar(question: question)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            VStack {
                Button(action: {
                    if !landingViewData.controller.randomMode(serieses: Array(serieses)) {
                        landingViewData.back(with: DrinkMakerWarning(id: ObjectIdentifier(Self.self), message: "Random failed: Not enough drink."))
                    }
                }, label: {
                    SubmitButtonView(title: "Start with random drink")
                })
                Button(action: {
                    landingViewData.controller.pracitcePreparingMode()
                }, label: {
                    SubmitButtonView(title: "Start with specific drink")
                })
                Button(action: {
                    landingViewData.back()
                }, label: {
                    SubmitButtonView(title: "Return to main menu", backgroundColor: Color.red)
                })
            }
        }
    }
    
    @ViewBuilder
    var versionCreator: some View {
        VStack {
            DrinkMakerProductContainerContentView()
                .environmentObject(drinkMakerData)
            VStack {
                Button(action: {
                    landingViewData.controller.creatorMode()
                }, label: {
                    SubmitButtonView(title: "Start again")
                })
                Button(action: {
                    landingViewData.back()
                }, label: {
                    SubmitButtonView(title: "Return to main menu", backgroundColor: Color.red)
                })
            }
        }
    }
    
    @ViewBuilder
    var examResult: some View {
        VStack {
            DrinkMakerExamResultListView(drinkMakerData)
                .environmentObject(DrinkMakerExamResultData())
            Button(action: {
                landingViewData.back()
            }, label: {
                SubmitButtonView(title: "Return to main menu", backgroundColor: Color.red)
            })
        }
    }
    
    
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            landingViewData.send(DrinkMakerWarning(id: ObjectIdentifier(Self.self), message: "Save failed"))
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
