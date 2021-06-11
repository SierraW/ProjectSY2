//
//  AmountAndUnitSelectionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-05-27.
//

import SwiftUI
import Combine

class AmountAndUnitSelectionData: ObservableObject {
    var showTitle = false
    @Published var ingredient: Ingredient
    @Published var isEditingUnit: IngredientUnit? = nil
    @Published var unitName: String = ""
    @Published var isEditingAmount: IngredientAmount? = nil
    @Published var amountName: String = ""
    @Published var units: [IngredientUnit] = []
    @Published var selectedUnit: IngredientUnit? = nil
    @Published var selectedAmount: IngredientAmount? = nil
    @Published var amounts: [IngredientAmount] = []
    @Published var isShowingAUSelectionView = false
    
    init(_ ingredient: Ingredient) {
        self.ingredient = ingredient
        resetEverythingExceptIngredient()
        if let unitSet = ingredient.units as? Set<IngredientUnit> {
            units = unitSet.sorted(by: DrinkMakerComparator.compare(_:_:))
        }
        if let amountSet = ingredient.amounts as? Set<IngredientAmount> {
            amounts = amountSet.sorted(by: DrinkMakerComparator.compare(_:_:))
        }
    }
    
    private func resetEverythingExceptIngredient() {
        units = []
        selectedUnit = nil
        amounts = []
        isShowingAUSelectionView = false
        resetEditingData()
    }
    
    private func resetEditingData() {
        isEditingUnit = nil
        isEditingAmount = nil
    }
    
    func setFocusOnUnit(_ unit: IngredientUnit?) {
        if let unit = unit {
            unitName = unit.name ?? "Empty Name"
        }
        isEditingUnit = unit
    }
    
    func setFocusOnAmount(_ amount: IngredientAmount?) {
        if let amount = amount {
            amountName = amount.name ?? "Empty Name"
        }
        isEditingAmount = amount
    }
    
    func add(_ unit: IngredientUnit) {
        ingredient.addToUnits(unit)
        units.append(unit)
        setFocusOnUnit(unit)
    }
    
    func remove(_ unit: IngredientUnit) {
        ingredient.removeFromUnits(unit)
        if let index = units.firstIndex(of: unit) {
            units.remove(at: index)
        }
    }
    
    func add(_ amount: IngredientAmount) {
        ingredient.addToAmounts(amount)
        amounts.append(amount)
        setFocusOnAmount(amount)
    }
    
    func remove(_ amount: IngredientAmount) {
        ingredient.removeFromAmounts(amount)
        if let index = amounts.firstIndex(of: amount) {
            amounts.remove(at: index)
        }
    }
    
    func setUnit(_ unit: IngredientUnit?) {
        selectedUnit = unit
    }
    
    func setAmount(_ amount: IngredientAmount?) {
        selectedAmount = amount
    }
}

struct AmountAndUnitSelectionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var amountAndUnitSelectionData: AmountAndUnitSelectionData
    var allowEdit = true
    var selected: ((IngredientUnit, IngredientAmount) -> Void)?
    
    private func handleSet(_ unit: IngredientUnit) {
        if let selected = selected {
            if let amount = amountAndUnitSelectionData.selectedAmount {
                selected(unit, amount)
                return
            }
        }
        amountAndUnitSelectionData.setUnit(unit)
    }
    
    private func handleSet(_ amount: IngredientAmount) {
        if let selected = selected {
            if let unit = amountAndUnitSelectionData.selectedUnit {
                selected(unit, amount)
                return
            }
        }
        amountAndUnitSelectionData.setAmount(amount)
    }
    
    var body: some View {
        VStack {
            title
            HStack {
                VStack {
                    HStack {
                        Text("Amount List")
                        Spacer()
                        if allowEdit {
                            Button(action: {
                                addAmount()
                            }, label: {
                                Image(systemName: "plus.square.fill")
                                    .font(.title2)
                            })
                        }
                    }
                    amountList
                    Spacer()
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    HStack {
                        Text("Unit List")
                        Spacer()
                        if allowEdit {
                            Button(action: {
                                addUnit()
                            }, label: {
                                Image(systemName: "plus.square")
                                    .font(.title2)
                            })
                        }
                    }
                    unitList
                    Spacer()
                }
            }
        }
        .padding()
        .onAppear(perform: {
            if amountAndUnitSelectionData.units.count > 0 && !allowEdit {
                amountAndUnitSelectionData.selectedUnit = amountAndUnitSelectionData.units[0]
            }
        })
    }
    
    @ViewBuilder
    var title: some View {
        if amountAndUnitSelectionData.showTitle {
            HStack {
                Text("Amount and Unit")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var unitList: some View {
        if amountAndUnitSelectionData.units.isEmpty {
            VStack {
                Spacer()
                Text("Empty")
                    .foregroundColor(.gray)
                    .bold()
                Spacer()
            }
        } else {
            List {
                ForEach(amountAndUnitSelectionData.units) { unit in
                    if unit == amountAndUnitSelectionData.isEditingUnit {
                        HStack {
                            Image(systemName: "pencil")
                            TextField("Unit Name", text: $amountAndUnitSelectionData.unitName) { _ in} onCommit: {
                                saveUnit()
                            }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
                                .gesture(TapGesture().onEnded({ _ in
                                    saveUnit()
                                }))
                            Image(systemName: "clear")
                                .foregroundColor(.red)
                                .gesture(TapGesture().onEnded({ _ in
                                    amountAndUnitSelectionData.setFocusOnUnit(nil)
                                }))
                        }
                    } else if let selected = amountAndUnitSelectionData.selectedUnit, unit == selected {
                        HStack {
                            HStack {
                                Spacer()
                                Text("\(unit.name!)")
                                    .bold()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .gesture(TapGesture().onEnded({ _ in
                                amountAndUnitSelectionData.setUnit(nil)
                            }))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text(unit.name!)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if allowEdit {
                                withAnimation {
                                    amountAndUnitSelectionData.setFocusOnUnit(unit)
                                }
                            } else {
                                handleSet(unit)
                            }
                        }
                        .onLongPressGesture {
                            if allowEdit {
                                withAnimation {
                                    amountAndUnitSelectionData.setFocusOnUnit(unit)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var amountList: some View {
        if amountAndUnitSelectionData.amounts.isEmpty {
            VStack {
                Spacer()
                Text("Empty")
                    .foregroundColor(.gray)
                    .bold()
                Spacer()
            }
        } else {
            List {
                ForEach(amountAndUnitSelectionData.amounts) { amount in
                    if amount == amountAndUnitSelectionData.isEditingAmount {
                        HStack {
                            Image(systemName: "pencil")
                            TextField("Amount Name", text: $amountAndUnitSelectionData.amountName) { _ in} onCommit: {
                                saveAmount()
                            }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
                                .gesture(TapGesture().onEnded({ _ in
                                    saveAmount()
                                }))
                            Image(systemName: "clear")
                                .foregroundColor(.red)
                                .gesture(TapGesture().onEnded({ _ in
                                    amountAndUnitSelectionData.setFocusOnAmount(nil)
                                }))
                        }
                    } else if let selectedAmount = amountAndUnitSelectionData.selectedAmount, amount == selectedAmount {
                        HStack {
                            Spacer()
                            Text(amount.name!)
                                .bold()
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            amountAndUnitSelectionData.setAmount(nil)
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text(amount.name!)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if allowEdit {
                                withAnimation {
                                    amountAndUnitSelectionData.setFocusOnAmount(amount)
                                }
                            } else {
                                handleSet(amount)
                            }
                        }
                        .onLongPressGesture {
                            if allowEdit {
                                withAnimation {
                                    amountAndUnitSelectionData.setFocusOnAmount(amount)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addUnit() {
        let newUnit = IngredientUnit(context: viewContext)
        newUnit.name = "NewUnit"
        amountAndUnitSelectionData.add(newUnit)
    }
    
    private func saveUnit() {
        if let unit = amountAndUnitSelectionData.isEditingUnit {
            if amountAndUnitSelectionData.unitName == "" {
                amountAndUnitSelectionData.remove(unit)
            } else {
                unit.name = amountAndUnitSelectionData.unitName
            }
            save()
            amountAndUnitSelectionData.setFocusOnUnit(nil)
        }
    }
    
    private func addAmount() {
        let newAmount = IngredientAmount(context: viewContext)
        newAmount.name = "NewAmount"
        amountAndUnitSelectionData.add(newAmount)
    }
    
    private func saveAmount() {
        if let amount = amountAndUnitSelectionData.isEditingAmount {
            if amountAndUnitSelectionData.amountName == "" {
                amountAndUnitSelectionData.remove(amount)
            } else {
                amount.name = amountAndUnitSelectionData.amountName
            }
            save()
            amountAndUnitSelectionData.setFocusOnAmount(nil)
        }
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            // warning
        }
    }
}
