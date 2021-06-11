//
//  SeriesListView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-02.
//

import SwiftUI

struct SeriesListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Series.name, ascending: true)],
                  animation: .default)
    var serieses: FetchedResults<Series>
    @EnvironmentObject var pvData: ProductAndVersionData
    @Binding var isPresented: Bool
    @State var isShowingProductAndVersionView = false
    @State var selectedVersion: Version?
    @State var editingSeries: Series?
    @State var seriesName: String = ""
    var isEditable = true
    var selected: ((Version) -> Void)?
    var practiceModeAction: ((Version) -> Void)?
    var creativeModeAction: ((Version) -> Void)?
    @State var isDeleteFailed = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Series")
                        .font(.title)
                    Spacer()
                    Button("Add") {
                        addSeries()
                    }
                }
                seriesList
            }
            .padding()
            if isShowingProductAndVersionView {
                Divider()
                Section {
                    if selected == nil {
                        ProductAndVersionSelectionView(showTitle: true) { _, version in
                            selectedVersion = version
                        }
                            .environment(\.managedObjectContext, viewContext)
                            .environmentObject(pvData)
                    } else {
                        ProductAndVersionSelectionView(showTitle: true) { _, version in
                            isPresented.toggle()
                            selected!(version)
                        }
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(pvData)
                    }
                }
                .transition(.slide)
            }
            Spacer()
        }
        .sheet(item: $selectedVersion, content: { version in
            DrinkMakerProductContainerContentView(from: version, showProductName: true, showsIsotopeMenu: true, practiceModeAction: { version in
                if let practiceModeAction = practiceModeAction {
                    selectedVersion = nil
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                        practiceModeAction(version)
                        timer.invalidate()
                    }
                }
            }, creativeModeAction: { verison in
                if let creativeModeAction = creativeModeAction {
                    selectedVersion = nil
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                        creativeModeAction(version)
                        timer.invalidate()
                    }
                }
            })
        })
        .alert(isPresented: $isDeleteFailed, content: {
            Alert(title: Text("Delete failed."))
        })
    }
    
    @ViewBuilder
    var seriesList: some View {
        if serieses.isEmpty {
            HStack {
                Text("Empty")
                Spacer()
            }
        } else {
            List {
                ForEach(serieses) { ser in
                    if isEditable {
                        if editingSeries == ser {
                            HStack {
                                TextField("Name of Series", text: $seriesName)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.green)
                                    .gesture(TapGesture().onEnded({ _ in
                                        saveSeries()
                                    }))
                                Image(systemName: "clear")
                                    .foregroundColor(.red)
                                    .gesture(TapGesture().onEnded({ _ in
                                        setFocusOnSeries(nil)
                                    }))
                            }
                        } else {
                            HStack {
                                Text(ser.name ?? "Error item")
                                    .gesture(TapGesture().onEnded({ _ in
                                        if let series = pvData.series, series == ser {
                                            if isShowingProductAndVersionView {
                                                set(nil)
                                            } else {
                                                isShowingProductAndVersionView = true
                                            }
                                        } else {
                                            set(ser)
                                        }
                                    }))
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .gesture(TapGesture().onEnded({ _ in
                                        setFocusOnSeries(ser)
                                    }))
                            }
                        }
                    } else {
                        HStack {
                            Text(ser.name ?? "Error item")
                                .gesture(TapGesture().onEnded({ _ in
                                    if let series = pvData.series, series == ser {
                                        if isShowingProductAndVersionView {
                                            set(nil)
                                        } else {
                                            isShowingProductAndVersionView = true
                                        }
                                    } else {
                                        set(ser)
                                    }
                                }))
                            Spacer()
                        }
                    }
                }
                .onDelete(perform: deleteContainers(_:))
                .deleteDisabled(!isEditable)
            }
        }
    }
    
    private func deleteContainers(_ indexSet: IndexSet) {
        for index in indexSet {
            viewContext.delete(serieses[index])
        }
        save()
    }
    
    private func set(_ series: Series?) {
        if let series = series {
            pvData.set(series)
        }
        isShowingProductAndVersionView = series != nil
    }
    
    private func addSeries() {
        let series = Series(context: viewContext)
        series.name = "New Series"
        save()
    }
    
    private func setFocusOnSeries(_ series: Series?) {
        editingSeries = series
        if let series = series {
            seriesName = series.name ?? "Error item"
        }
    }
    
    private func saveSeries() {
        if let series = editingSeries, seriesName != "" {
            series.name = seriesName
            save()
            setFocusOnSeries(nil)
        }
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            // catch exception
        }
    }
}

struct SeriesListView_Previews: PreviewProvider {
    static var previews: some View {
        SeriesListView(isPresented: .constant(true))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(ProductAndVersionData())
    }
}
