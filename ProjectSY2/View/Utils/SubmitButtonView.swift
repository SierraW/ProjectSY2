//
//  SubmitButtonView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-26.
//

import SwiftUI

struct SubmitButtonView: View {
    var title: String
    var font: CGFloat = 20
    var foregroundColor = Color.white
    var backgroundColor = Color.green
    
    var body: some View {
        ZStack{
            backgroundColor.edgesIgnoringSafeArea(.horizontal)
            Text(title)
                .foregroundColor(foregroundColor)
                .font(.system(size: font, weight: .bold, design: .default))
        }
        .frame(height: 50)
    }
}

struct SubmitButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitButtonView(title: "Submit", font: 30)
    }
}
