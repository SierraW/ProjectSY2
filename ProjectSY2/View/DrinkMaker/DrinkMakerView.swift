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
    
    func set(_ question: Question) {
        self.question = question
        mode = .Practice
    }
    
    func set(_ exam: Exam) {
        self.exam = exam
        mode = .Exam
    }
    
    func set() {
        mode = .Creator
    }
    
}

struct DrinkMakerView: View {
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
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                VStack {
                    Text("gu")
                }
            }
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: .zero, alignment: .topLeading)
            HStack {
                Text("Preparing Zone")
                    .font(.title3)
                    .bold()
                Spacer()
            }
            .padding()
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                VStack {
                    Text("gu")
                }
            }
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: .zero, alignment: .topLeading)
            Spacer()
        }
    }
}

struct DrinkMakerView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerView()
            .environmentObject(DrinkMakerData())
    }
}
