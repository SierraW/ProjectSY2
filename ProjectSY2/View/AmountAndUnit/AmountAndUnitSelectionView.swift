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
    @Published var isEditingUnitIndex: Int? = nil
    @Published var unitName: String = ""
    @Published var isEditingAmountIndex: Int? = nil
    @Published var amountName: String = ""
    @Published var units: [IngredientUnit] = []
    @Published var selectedUnit: IngredientUnit? = nil
    @Published var amounts: [IngredientUnitAmount] = []
    @Published var isShowingAUSelectionView = false
    
    init(_ ingredient: Ingredient) {
        self.ingredient = ingredient
        resetEverythingExceptIngredient()
        if let us = ingredient.units {
            units = Array(us as! Set<IngredientUnit>)
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
        isEditingUnitIndex = nil
        isEditingAmountIndex = nil
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
        amounts = []
    }
    
    func setFocusOnUnit(_ index: Int?) {
        if let index = index {
            isEditingUnitIndex = index
            unitName = units[index].name ?? "Empty Name"
        } else {
            isEditingUnitIndex = nil
        }
    }
    
    func setFocusOnAmount(_ index: Int?) {
        if let index = index {
            isEditingAmountIndex = index
            amountName = amounts[index].name ?? "Empty Name"
        } else {
            isEditingAmountIndex = nil
        }
    }
    
    func addUnit(_ unit: IngredientUnit) {
        ingredient.addToUnits(unit)
        units = Array(ingredient.units as! Set<IngredientUnit>)
        setFocusOnUnit(units.count - 1)
    }
    
    func addAmount(_ amount: IngredientUnitAmount) {
        if selectedUnit == nil {
            return
        }
        selectedUnit!.addToAmounts(amount)
        amounts = Array(selectedUnit!.amounts as! Set<IngredientUnitAmount>)
        setFocusOnAmount(amounts.count - 1)
    }
}

struct AmountAndUnitSelectionView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var amountAndUnitSelectionData: AmountAndUnitSelectionData
    
    var body: some View {
        VStack {
            title
            HStack {
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
                Spacer()
                Divider()
                Spacer()
                VStack {
                    HStack {
                        Text("Amount List")
                        Spacer()
                        Button(action: {
                            // add amount
                        }, label: {
                            Image(systemName: "plus.square.fill")
                                .font(.title2)
                        })
                    }
                    amountList
                    Spacer()
                }
            }
        }
        .padding()
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
                ForEach(amountAndUnitSelectionData.units.indices) { unitIndex in
                    if let index = amountAndUnitSelectionData.isEditingUnitIndex, index == unitIndex {
                        HStack {
                            TextField("Unit Name", text: $amountAndUnitSelectionData.unitName)
                            Spacer()
                            Button(action: {
                                saveUnit()
                            }, label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.green)
                            })
                            Button(action: {
                                amountAndUnitSelectionData.setFocusOnUnit(nil)
                            }, label: {
                                Image(systemName: "clear")
                                    .foregroundColor(.red)
                            })
                        }
                    } else if let unit = amountAndUnitSelectionData.units[unitIndex], let selected = amountAndUnitSelectionData.selectedUnit, unit == selected {
                        HStack {
                            ZStack {
                                Color.gray
                                Text(amountAndUnitSelectionData.units[unitIndex].name!)
                                    .bold()
                            }
                            .gesture(TapGesture().onEnded({ _ in
                                amountAndUnitSelectionData.set(nil)
                            }))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text(amountAndUnitSelectionData.units[unitIndex].name!)
                                .gesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            amountAndUnitSelectionData.set(amountAndUnitSelectionData.units[unitIndex])
                                        }
                                )
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .gesture(TapGesture().onEnded({ _ in
                                    amountAndUnitSelectionData.setFocusOnUnit(0)
                                }))
                        }
                    }
                }
            }
        }
    }
    
    var editButton: some View {
        return Button(action: {
            amountAndUnitSelectionData.setFocusOnUnit(0)
        }, label: {
            Image(systemName: "pencil")
                .foregroundColor(.blue)
        })
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
                ForEach(amountAndUnitSelectionData.amounts.indices) { amountIndex in
                    if let index = amountAndUnitSelectionData.isEditingAmountIndex, index == amountIndex {
                        HStack {
                            TextField("Amount Name", text: $amountAndUnitSelectionData.amountName)
                            Spacer()
                            Button(action: {
                                saveUnit()
                            }, label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.green)
                            })
                            Button(action: {
                                amountAndUnitSelectionData.setFocusOnAmount(nil)
                            }, label: {
                                Image(systemName: "clear")
                                    .foregroundColor(.red)
                            })
                        }
                    } else {
                        HStack {
                            Text(amountAndUnitSelectionData.amounts[amountIndex].name!)
                            Spacer()
                            Button(action: {
                                amountAndUnitSelectionData.setFocusOnAmount(amountIndex)
                            }, label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            })
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
        if let index = amountAndUnitSelectionData.isEditingUnitIndex {
            let unit = amountAndUnitSelectionData.units[index]
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
        if let index = amountAndUnitSelectionData.isEditingAmountIndex {
            let amount = amountAndUnitSelectionData.amounts[index]
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
