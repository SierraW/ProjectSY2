//
//  LabelledDivider.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-09.
//

import SwiftUI

struct LabelledDivider: View {

    let image: Image?
    let label: Text?
    let horizontalPadding: CGFloat
    let color: Color

    init(image: Image, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.image = image
        self.label = nil
        self.horizontalPadding = horizontalPadding
        self.color = color
    }
    
    init(label: Text, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.image = nil
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        HStack {
            line
            if let image = image {
                image.foregroundColor(color).imageScale(.large)
            } else if let label = label {
                label.foregroundColor(color)
            }
            line
        }
    }

    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}

struct LabelledDivider_Previews: PreviewProvider {
    static var previews: some View {
        LabelledDivider(image: Image(systemName: "pencil"))
    }
}
