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
            Section {
                if let question = drinkMakerData.question, landingViewData.controller.checkError(for: question) {
                    Text("Correct")
                        .foregroundColor(.green)
                } else {
                    Text("Wrong")
                        .foregroundColor(.red)
                }
            }
            HStack {
                VStack {
                    Text("Your Answer")
                    DrinkMakerProductContainerContentView()
                        .environmentObject(drinkMakerData)
                }
                if let question = drinkMakerData.question, let version = question.version {
                    VStack {
                        Text("Correct Answer")
                        DrinkMakerProductContainerContentView(from: version)
                    }
                }
            }
            VStack {
                Button(action: {
                    landingViewData.controller.pracitcePreparingMode()
                }, label: {
                    SubmitButtonView(title: "Start again")
                })
                Button(action: {
                    landingViewData.isShowingMainMenu = true
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
                    landingViewData.isShowingMainMenu = true
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
                    .font(.title)
            }
            if let exam = drinkMakerData.exam {
                HStack {
                    Text("Correct")
                    Text("\(landingViewData.controller.checkAll(for: exam))")
                }
                HStack {
                    Text("Total")
                    Text("\(exam.questions?.count ?? 0)")
                }
            }
            
            Button(action: {
                landingViewData.isShowingMainMenu = true
            }, label: {
                SubmitButtonView(title: "Return to main menu", backgroundColor: Color.red)
            })
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
