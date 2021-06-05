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
    @Published var isEditingAmount: IngredientUnitAmount? = nil
    @Published var amountName: String = ""
    @Published var units: [IngredientUnit] = []
    @Published var selectedUnit: IngredientUnit? = nil
    @Published var amounts: [IngredientUnitAmount] = []
    @Published var isShowingAUSelectionView = false
    @Published var warningUnitIsNotSelected = false
    
    init(_ ingredient: Ingredient) {
        self.ingredient = ingredient
        resetEverythingExceptIngredient()
        if let us = ingredient.units {
            units = Array(us as! Set<IngredientUnit>)
        }
        if units.count > 0 {
            set(units[0])
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
    
    func set(_ i: Ingredient) {
        resetEverythingExceptIngredient()
        self.ingredient = i
        if let units = i.units {
            self.units = Array(units as! Set<IngredientUnit>)
        }
        isShowingAUSelectionView = true
    }
    
    func set(_ iu: IngredientUnit?) {
        selectedUnit = iu
        resetEditingData()
        if let iu = iu, let amounts = iu.amounts {
            self.amounts = Array(amounts as! Set<IngredientUnitAmount>)
        }
    }
    
    func setFocusOnUnit(_ unit: IngredientUnit?) {
        if let unit = unit {
            unitName = unit.name ?? "Empty Name"
        }
        isEditingUnit = unit
    }
    
    func setFocusOnAmount(_ amount: IngredientUnitAmount?) {
        if let amount = amount {
            amountName = amount.name ?? "Empty Name"
        }
        isEditingAmount = amount
    }
    
    func addUnit(_ unit: IngredientUnit) {
        ingredient.addToUnits(unit)
        units.append(unit)
        setFocusOnUnit(unit)
    }
    
    func addAmount(_ amount: IngredientUnitAmount) {
        if selectedUnit == nil {
            warningUnitIsNotSelected = true
            return
        }
        selectedUnit!.addToAmounts(amount)
        amounts.append(amount)
        setFocusOnAmount(amount)
    }
}

struct AmountAndUnitSelectionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var amountAndUnitSelectionData: AmountAndUnitSelectionData
    var selected: ((IngredientUnit, IngredientUnitAmount) -> Void)?
    
    var body: some View {
        VStack {
            title
            HStack {
                VStack {
                    HStack {
                        Text("Amount List")
                        Spacer()
                        Button(action: {
                            addAmount()
                        }, label: {
                            Image(systemName: "plus.square.fill")
                                .font(.title2)
                        })
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
                        Button(action: {
                            addUnit()
                        }, label: {
                            Image(systemName: "plus.square")
                                .font(.title2)
                        })
                    }
                    unitList
                    Spacer()
                }
            }
        }
        .padding()
        .alert(isPresented: $amountAndUnitSelectionData.warningUnitIsNotSelected, content: {
            Alert(title: Text("Please select a unit first."))
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
            HStack {
                Text("Empty...")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            List {
                ForEach(amountAndUnitSelectionData.units) { unit in
                    if unit == amountAndUnitSelectionData.isEditingUnit {
                        HStack {
                            TextField("Unit Name", text: $amountAndUnitSelectionData.unitName)
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
                                Text("> \(unit.name!)")
                                    .bold()
                                Spacer()
                            }
                            .gesture(TapGesture().onEnded({ _ in
                                amountAndUnitSelectionData.set(nil)
                            }))
                            Spacer()
                        }
                    } else {
                        HStack {
                            HStack {
                                Spacer()
                                Text(unit.name!)
                                Spacer()
                            }
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            amountAndUnitSelectionData.set(unit)
                                        }
                                )
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .gesture(TapGesture().onEnded({ _ in
                                    amountAndUnitSelectionData.setFocusOnUnit(unit)
                                }))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var amountList: some View {
        if amountAndUnitSelectionData.selectedUnit == nil {
            VStack {
                Spacer()
                Text("Please select a unit")
                    .foregroundColor(.gray)
                    .bold()
                Spacer()
            }
        } else if amountAndUnitSelectionData.amounts.isEmpty {
            HStack {
                Text("Empty...")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            List {
                ForEach(amountAndUnitSelectionData.amounts) { amount in
                    if amount == amountAndUnitSelectionData.isEditingAmount {
                        HStack {
                            TextField("Amount Name", text: $amountAndUnitSelectionData.amountName)
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
                    } else {
                        HStack {
                            HStack {
                                Spacer()
                                Text(amount.name!)
                                Spacer()
                            }
                            .gesture(TapGesture().onEnded({ _ in
                                if selected != nil {
                                    selected!(amountAndUnitSelectionData.selectedUnit!, amount)
                                }
                            }))
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .gesture(TapGesture().onEnded({ _ in
                                    amountAndUnitSelectionData.setFocusOnAmount(amount)
                                }))
                        }
                    }
                }
            }
        }
    }
    
    private func verifyUnitNameField() -> Bool {
        return amountAndUnitSelectionData.unitName != ""
    }
    
    private func verifyAmountNameField() -> Bool {
        return amountAndUnitSelectionData.amountName != ""
    }
    
    private func addUnit() {
        let newUnit = IngredientUnit(context: viewContext)
        newUnit.name = "New Unit"
        amountAndUnitSelectionData.addUnit(newUnit)
    }
    
    private func saveUnit() {
        if !verifyUnitNameField() {
            return
        }
        if let unit = amountAndUnitSelectionData.isEditingUnit {
            unit.name = amountAndUnitSelectionData.unitName
            save()
            amountAndUnitSelectionData.setFocusOnUnit(nil)
        }
    }
    
    private func addAmount() {
        let newAmount = IngredientUnitAmount(context: viewContext)
        newAmount.name = "New Amount"
        amountAndUnitSelectionData.addAmount(newAmount)
    }
    
    private func saveAmount() {
        if !verifyAmountNameField() {
            return
        }
        if let amount = amountAndUnitSelectionData.isEditingAmount {
            amount.name = amountAndUnitSelectionData.amountName
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
