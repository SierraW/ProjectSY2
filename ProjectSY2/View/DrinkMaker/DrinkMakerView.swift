//
//  DrinkMakerView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI
import Combine

class DrinkMakerData: ObservableObject {
    @Published var exam: Exam? = nil
    @Published var question: Question? = nil
    @Published var productContainer: ProductContainer? = nil
    @Published var steps: [Step] = []
    @Published var histories: [History] = []
    @Published var mode: DrinkMakerView.Mode = .Creator
    @Published var isLoading = false
    @Published var isDrinkMaking = false
    @Published var isShowingPCSelectionView = false
    @Published var isShowingContainerSelectionView = false
    @Published var isShowingContainerEditingView = false
    var drinkMakerContainerData: DrinkMakerContainerData? = nil
    
    func set(_ question: Question) {
        self.question = question
        mode = .Practice
    }
    
    func set(_ exam: Exam) {
        self.exam = exam
        mode = .Exam
    }
    
    func set(_ history: History) {
        drinkMakerContainerData = DrinkMakerContainerData(history)
        isShowingContainerEditingView = true
    }
    
    func set() {
        mode = .Creator
    }
    
}

struct DrinkMakerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var drinkMakerData: DrinkMakerData
    
    
    enum Mode: String {
        case Creator
        case Practice
        case Exam
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("DrinkMarker™")
                        .font(.title)
                    Spacer()
                }
                HStack {
                    Text("RamdomMachine: ON")
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    Text(drinkMakerData.mode.rawValue)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.bottom, 10)
                HStack {
                    Text("Production Zone")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
            }
            .padding()
            productContainer
            HStack {
                Text("Preparation Zone")
                    .font(.title3)
                    .bold()
                Spacer()
            }
            .padding()
            containList
            Spacer()
            Button(action: {
                
            }, label: {
                SubmitButtonView(title: "Submit")
            })
        }
        .sheet(isPresented: $drinkMakerData.isShowingPCSelectionView, content: {
            ProductContainerListView { selectedContainer in
                drinkMakerData.productContainer = selectedContainer
                drinkMakerData.steps = []
                drinkMakerData.isShowingPCSelectionView = false
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(ProductContainerAdditionData(nil))
        })
        .sheet(isPresented: $drinkMakerData.isShowingContainerSelectionView, content: {
            ContainerListView(isDeleteDisabled: true) { container in
                let history = History(context: viewContext)
                history.container = container
                drinkMakerData.histories.append(history)
                drinkMakerData.isShowingContainerSelectionView = false
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(ContainerData())
        })
        .sheet(isPresented: $drinkMakerData.isShowingContainerEditingView, content: {
            DrinkMakerContainerView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(drinkMakerData.drinkMakerContainerData!)
        })
    }
    
    @ViewBuilder
    var productContainer: some View {
        if drinkMakerData.productContainer == nil {
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                VStack {
                    Text("Click to select a product container")
                        .foregroundColor(.gray)
                }
            }
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: .zero, alignment: .topLeading)
            .gesture(TapGesture().onEnded({ _ in
                drinkMakerData.isShowingPCSelectionView = true
            }))
        } else {
            VStack {
                Text(drinkMakerData.productContainer!.name ?? "Error item")
                HStack {
                    List {
                        ForEach(drinkMakerData.steps) { step in
                            Text(step.stepName ?? "Error item")
                        }
                    }
                }
            }
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 150, alignment: .topLeading)
        }
    }
    
    @ViewBuilder
    var containList: some View {
        if drinkMakerData.histories.isEmpty {
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                VStack {
                    Text("Click to select a container")
                        .foregroundColor(.gray)
                }
            }
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: .zero, alignment: .topLeading)
            .gesture(TapGesture().onEnded({ _ in
                drinkMakerData.isShowingContainerSelectionView = true
            }))
        } else {
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                List {
                    ForEach(drinkMakerData.histories) { histroy in
                        VStack {
                            Text(histroy.container?.name ?? "Error type")
                        }
                        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 200, alignment: .topLeading)
                        .gesture(TapGesture().onEnded({ _ in
                            drinkMakerData.set(histroy)
                        }))
                    }
                }
            }
        }
    }
}

struct DrinkMakerView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(DrinkMakerData())
    }
}
