//
//  DrinkMakerComparisonView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-08.
//

import SwiftUI

struct DrinkMakerComparisonView: View {
    var isSuccessful = false
    
    var originalProductContainer: ProductContainer?
    var originalSteps: [Step] = []
    
    var comparedProductContainer: ProductContainer?
    var comparedSteps: [Step] = []
    
    init(from question: Question) {
        if let version = question.version, let opc = version.productContainer, let ost = version.steps as? Set<Step>, let cpc = question.productContainer, let cst = question.steps as? Set<Step> {
            originalProductContainer = opc
            originalSteps = Array(ost)
            comparedProductContainer = cpc
            comparedSteps = Array(cst)
            isSuccessful = true
        }
    }
    
    var body: some View {
        if isSuccessful {
            VStack {
                Text("Result")
                HStack {
                    VStack {
                        Text("Your Answer")
                            .bold()
                            .foregroundColor(.red)
                        DrinkMakerProductContainerContentView(name: nil, productContainer: comparedProductContainer!, steps: comparedSteps)
                    }
                    Divider()
                    VStack {
                        Text("Correct Answer")
                            .bold()
                            .foregroundColor(.green)
                        DrinkMakerProductContainerContentView(name: nil, productContainer: originalProductContainer!, steps: originalSteps)
                    }
                }
                Spacer()
            }
            .padding()
        } else {
            Text("Error, please file a bug")
        }
    }
}

struct DrinkMakerComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerComparisonView(from: Question())
    }
}
