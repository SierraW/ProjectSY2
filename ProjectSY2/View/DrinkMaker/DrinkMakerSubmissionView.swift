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
    @State var warningSaveFailed = false
    
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
        .alert(isPresented: $warningSaveFailed, content: {
            Alert(title: Text("Save failed"))
        })
    }
    
    @ViewBuilder
    var compareView: some View {
        VStack {
            if let question = drinkMakerData.question {
                DrinkMakerComparisonView(from: question)
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
            HStack {
                Text("Exam Result")
                    .font(.title2)
                    .padding(.trailing, 10)
                if let questionSet = drinkMakerData.exam?.questions as? Set<Question> {
                    DrinkMakerExamResultScoreWidgit(numberOfTotalQuestion: questionSet.count, numberOfCorrectQuestion: countCorrect(from: questionSet))
                }
            }
            DrinkMakerExamResultListView(drinkMakerData)
                .environmentObject(DrinkMakerExamResultData())
            Button(action: {
                landingViewData.back()
            }, label: {
                SubmitButtonView(title: "Return to main menu", backgroundColor: Color.red)
            })
        }
    }
    
    private func countCorrect(from questionSet: Set<Question>) -> Int {
        var counter = 0
        questionSet.forEach { question in
            if question.isCorrect {
                counter += 1
            }
        }
        return counter
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
