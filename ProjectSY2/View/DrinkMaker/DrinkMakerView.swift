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
    @Published var version: Version? = nil
    @Published var productContainer: ProductContainer? = nil
    @Published var steps: [Step] = []
    @Published var ingredients: [Ingredient] = []
    @Published var operations: [Operation] = []
    // container
    @Published var history: History? = nil
    @Published var historyContainer: Container? = nil
    @Published var historySteps: [Step] = []
    @Published var historyIngredients: [Ingredient] = []
    @Published var historyOperations: [Operation] = []
    
    @Published var mode: Mode = .Creator
    @Published var isLoading = false
    @Published var isSubmitted = false
    @Published var isDrinkMaking = false
    @Published var isShowingPCSelectionView = false
    @Published var isShowingContainerSelectionView = false
    @Published var isShowingContainerEditingView = false
    @Published var isShowingVersionSelectionView = false
    var identifierGenerator = 0
    var productName: String {
        if let version = version, let product = version.product {
            return "\(product.name ?? "Unnamed Product") - \(version.name ?? "Normal")"
        } else {
            return "new product..."
        }
    }
    
    enum Mode: String {
        case Creator
        case Practice
        case Exam
    }
    
    func reset() {
        exam = nil
        question = nil
        version = nil
        productContainer = nil
        steps = []
        ingredients = []
        operations = []
        
        history = nil
        historyContainer = nil
        historySteps = []
        historyIngredients = []
        historyOperations = []
        
        mode = .Creator
        isLoading = false
        isSubmitted = false
        isDrinkMaking = false
        isShowingPCSelectionView = false
        isShowingContainerSelectionView = false
        isShowingContainerEditingView = false
        identifierGenerator = 0
    }
    
    func generateId() -> Int32 {
        identifierGenerator += 1
        return Int32(identifierGenerator)
    }
    
    func set(_ productContainer: ProductContainer) {
        withAnimation {
            self.productContainer = productContainer
            self.steps = []
            if let ingredientSet = productContainer.ingredients as? Set<Ingredient> {
                self.ingredients = ingredientSet.sorted(by: DrinkMakerComparator.compare(_:_:))
            } else {
                self.ingredients = []
            }
            if let operationSet = productContainer.operations as? Set<Operation> {
                self.operations = operationSet.sorted(by: DrinkMakerComparator.compare(_:_:))
            } else {
                self.operations = []
            }
            self.isShowingPCSelectionView = false
        }
    }
    
    func set(_ container: Container, with history: History) {
        history.identifier = generateId()
        history.container = container
        self.history = history
        if let container = history.container {
            self.historySteps = []
            self.historyContainer = container
            if let ingredients = container.ingredients as? Set<Ingredient> {
                self.historyIngredients = ingredients.sorted(by: DrinkMakerComparator.compare(_:_:))
            } else {
                self.historyIngredients = []
            }
            if let operations = container.operations as? Set<Operation> {
                self.historyOperations = operations.sorted(by: DrinkMakerComparator.compare(_:_:))
            } else {
                self.historyOperations = []
            }
        }
        isShowingContainerSelectionView = false
    }
    
    func remove() {
        history = nil
    }
}

struct DrinkMakerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var drinkMakerData: DrinkMakerData
    @EnvironmentObject var landingViewData: LandingViewData
    var controller: DrinkMakerController {
        landingViewData.controller
    }
    @State var isReadyGoBack = false
    @State var isReadyForSubmit = false
    @State var isShowingStepsDetail = false
    @State var isShowingIngredientSelectionView = false
    @State var isShowingOperationSelectionView = false
    @State var isPresentProductContainerContentView = false
    @State var timer: Timer?
    
    var body: some View {
        if drinkMakerData.isSubmitted {
            DrinkMakerSubmissionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(drinkMakerData)
        } else if drinkMakerData.isLoading {
            DrinkMakerLoadingView(controller: DrinkMakerController(drinkMakerData))
                .environmentObject(drinkMakerData)
                .environmentObject(landingViewData)
        } else {
            VStack {
                VStack {
                    HStack {
                        Section {
                            if isReadyGoBack {
                                Button(action: {
                                    withAnimation {
                                        landingViewData.isShowingMainMenu.toggle()
                                    }
                                }, label: {
                                    Text("Go Back")
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                })
                                .transition(.slide)
                            } else {
                                Text("DrinkMaker???")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .transition(.opacity)
                                    .gesture(TapGesture().onEnded({ _ in
                                        withAnimation {
                                            readyForGoingBack()
                                        }
                                    }))
                            }
                        }
                        .frame(width: 300, height: 30, alignment: .leading)
                        Spacer()
                        Text(drinkMakerData.mode.rawValue)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    banner
                        .padding(.bottom, 10)
                    HStack {
                        Text("Production Zone")
                            .font(.title3)
                        Spacer()
                    }
                    .padding(.bottom, 7)
                }
                .padding(.horizontal, 10)
                productContainer
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 320, maxHeight: .infinity, alignment: .topLeading)
                HStack {
                    Text("Preparation Zone")
                        .font(.title3)
                        .gesture(TapGesture().onEnded({ _ in
                            minimizedExtendedIOView()
                        }))
                    Spacer()
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                if !isShowingIngredientSelectionView && !isShowingOperationSelectionView {
                    containerView
                        .transition(.opacity)
                        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: .infinity, alignment: .topLeading)
                }
                Button(action: {
                    submit()
                }, label: {
                    if isReadyForSubmit {
                        SubmitButtonView(title: "Confirm Submit", backgroundColor: Color.red)
                    } else {
                        SubmitButtonView(title: "Submit")
                    }
                })
            }
            .sheet(isPresented: $drinkMakerData.isShowingVersionSelectionView, content: {
                SeriesListView(isPresented: $drinkMakerData.isShowingVersionSelectionView) { version in
                    drinkMakerData.version = version
                }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(ProductAndVersionData())
            })
            .sheet(isPresented: $drinkMakerData.isShowingContainerEditingView, content: {
                DrinkMakerContainerView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(drinkMakerData)
            })
            .sheet(isPresented: $isPresentProductContainerContentView, content: {
                VStack {
                    Spacer()
                    DrinkMakerProductContainerContentView(from: drinkMakerData.question!.version!, showProductName: true)
                        .environmentObject(drinkMakerData)
                    Spacer()
                }
            })
        }
    }
    
    @ViewBuilder
    var productContainer: some View {
        if let _ = drinkMakerData.productContainer {
            VStack {
                HStack {
                    if let name = drinkMakerData.productContainer?.name {
                        Text(name)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            controller.startOver()
                        }
                    }, label: {
                        Text("Start Over")
                            .foregroundColor(.red)
                    })
                }
                DrinkMakerContainerContentLivePreviewView(steps: $drinkMakerData.steps)
                    .frame(width: 380, height: 230, alignment: .center)
                HStack {
                    Button(action: {
                        withAnimation {
                            if isShowingOperationSelectionView {
                                isShowingOperationSelectionView = false
                            }
                            isShowingIngredientSelectionView.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("Add Ingredient")
                            Image(systemName: "chevron.right.circle")
                                .imageScale(.large)
                                .rotationEffect(.degrees(isShowingIngredientSelectionView ? 90 : 0))
                        }
                        
                    })
                    Spacer()
                    Button(action: {
                        withAnimation {
                            if isShowingIngredientSelectionView {
                                isShowingIngredientSelectionView = false
                            }
                            isShowingOperationSelectionView.toggle()
                        }
                    }, label: {
                        HStack {
                            Text("Operations")
                            Image(systemName: "chevron.right.circle")
                                .imageScale(.large)
                                .rotationEffect(.degrees(isShowingOperationSelectionView ? 90 : 0))
                        }
                        
                    })
                }
                Section {
                    if isShowingIngredientSelectionView {
                        IngredientAmountUnitSelectionView(ingredients: drinkMakerData.ingredients) { ingredient, unit, amount in
                            withAnimation {
                                addToProductContainer(ingredient, unit: unit, amount: amount)
                            }
                        }
                    }
                    if isShowingOperationSelectionView {
                        if drinkMakerData.operations.isEmpty {
                            Text("Empty")
                        } else {
                            List {
                                ForEach(drinkMakerData.operations) { operation in
                                    Button(action: {
                                        withAnimation {
                                            addToProductContainer(operation)
                                        }
                                    }, label: {
                                        Text(operation.name ?? "Error item")
                                    })
                                }
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
            .padding(.horizontal, 10)
        } else {
            if drinkMakerData.isShowingPCSelectionView {
                ProductContainerListView(showTitle: false) { selectedContainer in
                    withAnimation {
                        drinkMakerData.set(selectedContainer)
                    }
                }
                .border(Color.gray, width: 1)
                .padding()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(ProductContainerAdditionData(nil))
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Click here to select a product container")
                        Spacer()
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .gesture(TapGesture().onEnded({ _ in
                    withAnimation {
                        drinkMakerData.isShowingPCSelectionView = true
                    }
                }))
            }
        }
    }
    
    @ViewBuilder
    var banner: some View {
        if drinkMakerData.mode == .Creator {
            HStack {
                Button(drinkMakerData.productName) {
                    drinkMakerData.isShowingVersionSelectionView = true
                }
                Spacer()
            }
        } else if drinkMakerData.mode == .Exam, let exam = drinkMakerData.exam {
            HStack {
                Text("\(drinkMakerData.question?.version?.product?.name ?? "Error item") - \(drinkMakerData.question?.version?.name ?? "Error item")")
                    .font(.title2)
                    .bold()
                Spacer()
                Text("\(exam.answered) / \(exam.questions?.count ?? 0)")
                    .bold()
            }
        } else {
            HStack {
                Button(action: {
                    isPresentProductContainerContentView = true
                }, label: {
                    Text("\(drinkMakerData.question?.version?.product?.name ?? "Error item") - \(drinkMakerData.question?.version?.name ?? "Error item")")
                        .font(.title2)
                        .bold()
                        .help(Text("View answer"))
                })
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var containerView: some View {
        if let history = drinkMakerData.history {
            VStack {
                DrinkMakerContainerView(showActionField: false)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(drinkMakerData)
                    .gesture(TapGesture().onEnded({ _ in
                        minimizedExtendedIOView()
                        drinkMakerData.isShowingContainerEditingView = true
                    }))
                HStack {
                    Spacer()
                    Text("Discard")
                        .foregroundColor(.red)
                        .gesture(TapGesture().onEnded({ _ in
                            withAnimation {
                                discard()
                            }
                        }))
                        .padding(.trailing, 10)
                    Text("Pour in")
                        .foregroundColor(.blue)
                        .gesture(TapGesture().onEnded({ _ in
                            withAnimation {
                                pour(history)
                            }
                        }))
                        .padding(.trailing, 10)
                }
            }
        } else {
            if drinkMakerData.isShowingContainerSelectionView {
                ContainerListView(showTitle: false, isDeleteDisabled: true) { container in
                    withAnimation {
                        drinkMakerData.set(container, with: History(context: viewContext))
                        minimizedExtendedIOView()
                        drinkMakerData.isShowingContainerEditingView = true
                    }
                }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(ContainerData())
                .border(Color.gray, width: 1)
                .padding()
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Click here to select a container")
                        Spacer()
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .gesture(TapGesture().onEnded({ _ in
                    minimizedExtendedIOView()
                    drinkMakerData.isShowingContainerSelectionView = true
                }))
            }
        }
    }
    
    private func minimizedExtendedIOView() {
        withAnimation {
            if isShowingOperationSelectionView {
                isShowingOperationSelectionView = false
            }
            if isShowingIngredientSelectionView {
                isShowingIngredientSelectionView = false
            }
        }
    }
    
    private func addToProductContainer(_ ingredient: Ingredient, unit: IngredientUnit, amount: IngredientAmount) {
        let step = Step(context: viewContext)
        step.identifier = drinkMakerData.generateId()
        step.name = DrinkMakerFormatter.format(ingredient, unit, amount)
        drinkMakerData.steps.append(step)
    }
    
    private func addToProductContainer(_ operation: Operation) {
        let step = Step(context: viewContext)
        step.identifier = drinkMakerData.generateId()
        step.name = "\(operation.name ?? "Error item")"
        drinkMakerData.steps.append(step)
    }
    
    private func discard() {
        drinkMakerData.history = nil
    }
    
    private func pour(_ history: History) {
        if let _ = drinkMakerData.productContainer {
            let step = Step(context: viewContext)
            step.identifier = drinkMakerData.generateId()
            step.childHistory = history
            drinkMakerData.steps.append(step)
            drinkMakerData.remove()
        } else {
            sendWarning(with: "Product container is missing")
        }
    }
    
    private func sendWarning(with message: String) {
        landingViewData.send(DrinkMakerWarning(id: ObjectIdentifier(Self.self), message: message))
    }
    
    private func verifyFields() -> Bool {
        if drinkMakerData.productContainer == nil {
            sendWarning(with: "Product container is missing")
            return false
        }
        if drinkMakerData.steps.count == 0 {
            sendWarning(with: "Your drink must contains at least one step")
            return false
        }
        if drinkMakerData.mode == .Creator && drinkMakerData.version == nil {
            sendWarning(with: "Add or select a product by clicking \"new product\" button")
            return false
        }
        return true
    }
    
    private func readyForGoingBack() {
        if let timer = timer, timer.isValid {
            timer.fire()
        }
        isReadyGoBack = true
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            withAnimation {
                isReadyGoBack = false
            }
        })
    }
    
    private func submit() {
        if !verifyFields() {
            return
        }
        if !isReadyForSubmit {
            isReadyForSubmit = true
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                isReadyForSubmit = false
            })
            return
        }
        if let timer = timer, timer.isValid {
            timer.fire()
        }
        switch drinkMakerData.mode {
        case .Exam:
            if !controller.nextQuestion() {
                drinkMakerData.isSubmitted = true
            } else {
                controller.startOver()
            }
            save()
        case .Creator:
            controller.submitVersion()
            drinkMakerData.isSubmitted = true
            save()
        case .Practice:
            controller.submitQuestion()
            drinkMakerData.isSubmitted = true
        }
        
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            
        }
    }
}

struct DrinkMakerView_Previews: PreviewProvider {
    static var previews: some View {
        let data = DrinkMakerData()
        
        DrinkMakerView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(data)
            .environmentObject(LandingViewData())
    }
}
