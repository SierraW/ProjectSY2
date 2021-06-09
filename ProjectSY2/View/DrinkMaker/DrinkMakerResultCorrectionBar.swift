//
//  DrinkMakerResultCorrectionBar.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import SwiftUI

struct DrinkMakerResultCorrectionBar: View {
    @Environment(\.managedObjectContext) var viewContext
    var question: Question
    @State var activated = true
    let controller = DrinkMakerIsotopeController()
    
    var body: some View {
        Section {
            if activated {
                VStack {
                    Text("The answer for this question should be...")
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                let _ = controller.markAnswerWrong(from: question)
                            }
                        }, label: {
                            Text("Wrong")
                                .frame(width: 100, height: 40, alignment: .center)
                                .background(question.isCorrect ? Color.red : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        })
                        Spacer()
                        Button(action: {
                            withAnimation {
                                activated.toggle()
                            }
                        }, label: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .imageScale(.large)
                        })
                        Spacer()
                        Button(action: {
                            withAnimation {
                                let _ = controller.markAnswerRight(from: question, with: Isotope(context: viewContext))
                            }
                        }, label: {
                            Text("Right")
                                .frame(width: 100, height: 40, alignment: .center)
                                .background(question.isCorrect ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        })
                        Spacer()
                    }
                    .padding(.top, 1)
                }
                .transition(.move(edge: .leading))
            } else {
                Button(action: {
                    withAnimation {
                        activated.toggle()
                    }
                }, label: {
                    LabelledDivider(image: Image(systemName: "exclamationmark.triangle"), horizontalPadding: 20, color: .red)
                })
                .transition(.move(edge: .trailing))
            }
        }
    }
}
