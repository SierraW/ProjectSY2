//
//  DrinkMakerContainerContentLivePreviewView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-11.
//

import SwiftUI

struct DrinkMakerContainerContentLivePreviewView: View {
    @Binding var steps: [Step]
    @Namespace var bottomId
    
    init(steps: Binding<[Step]>) {
        self._steps = steps
    }
    
    var body: some View {
        livePreview
        .padding(.horizontal, 7)
    }
    
    @ViewBuilder
    var livePreview: some View {
        VStack {
            if steps.isEmpty {
                Text("Empty")
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack {
                            ForEach(steps, id: \.identifier) { step in
                                if let name = step.name {
                                    HStack {
                                        Text(name)
                                        Spacer()
                                    }
                                } else if let history = step.childHistory{
                                    DrinkMakerStepsView()
                                        .environmentObject(DrinkMakerStepsData(history))
                                }
                            }
                            Divider().id(bottomId)
                        }
                        .onChange(of: steps.count, perform: { _ in
                            withAnimation {
                                proxy.scrollTo(bottomId)
                            }
                        })
                    }
                }
            }
        }
    }
}

struct DrinkMakerContainerContentLivePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkMakerContainerContentLivePreviewView(steps: .constant([]))
    }
}
