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
    @Published var histories: [History] = []
    @Published var mode: Mode = .Creator
    @Published var isLoading = false
    @Published var isSubmitted = false
    @Published var isDrinkMaking = false
    @Published var isShowingPCSelectionView = false
    @Published var isShowingContainerSelectionView = false
    @Published var isShowingContainerEditingView = false
    @Published var isShowingVersionSelectionView = false
    var questions: [Question] = []
    var drinkMakerContainerData: DrinkMakerContainerData? = nil
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
        histories = []
        mode = .Creator
        isLoading = false
        isSubmitted = false
        isDrinkMaking = false
        isShowingPCSelectionView = false
        isShowingContainerSelectionView = false
        isShowingContainerEditingView = false
        drinkMakerContainerData = nil
        identifierGenerator = 0
    }
    
    func generateId() -> Int32 {
        identifierGenerator += 1
        return Int32(identifierGenerator)
    }
    
    func set(_ history: History) {
        drinkMakerContainerData = DrinkMakerContainerData(history)
        isShowingContainerEditingView = true
    }
    
    func set() {
        let timer = Timer(timeInterval: 1000, target: self, selector: #selector(loadQuestion), userInfo: nil, repeats: false)
        timer.fire()
    }
    
    @objc func loadQuestion() {
        if mode == .Exam {
            let count = exam?.answered ?? 0 + 1
            if count < questions.count{
                question = questions[Int(count)]
                isLoading = false
                return
            }
            submit()
        }
    }
    
    func remove(_ history: History) {
        if let index = histories.firstIndex(of: history) {
            histories.remove(at: index)
        }
    }
    
    func submit() {
        
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
    @State var isPresentAlert = false
    @State var alertType: AlertType = .stepsNotEnough
    @State var isShowingIngredientSelectionView = false
    @State var isShowingOperationSelectionView = false
    @State var isPresentProductContainerContentView = false
    @State var timer: Timer?
    
    enum AlertType {
        case productContainerIsMissing
        case stepsNotEnough
        case versionUnspecified
        
        func message() -> String {
            switch self {
            case .productContainerIsMissing:
                return "Product container is missing"
            case .versionUnspecified:
                return "Add or select a product by clicking \"new product\" button"
            default:
                return "Your drink must contains at least one step"
            }
        }
    }
    
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
                                Text("DrinkMaker™")
                                    .font(.title)
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
                            .font(.title2)
                            .bold()
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    banner
                        .padding(.bottom, 10)
                    HStack {
                        Text("Production Zone")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                }
                .padding()
                productContainer
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: .infinity, alignment: .topLeading)
                HStack {
                    Text("Preparation Zone")
                        .font(.title3)
                        .bold()
                        .gesture(TapGesture().onEnded({ _ in
                            minimizedExtendedIOView()
                        }))
                    Spacer()
                }
                .padding()
                if !isShowingIngredientSelectionView && !isShowingOperationSelectionView {
                    containList
                        .transition(.move(edge: .bottom))
                        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 230, alignment: .topLeading)
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
                .environmentObject(ProductAndVersionData(nil))
            })
            .sheet(isPresented: $drinkMakerData.isShowingPCSelectionView, content: {
                ProductContainerListView { selectedContainer in
                    drinkMakerData.productContainer = selectedContainer
                    drinkMakerData.steps = []
                    drinkMakerData.isShowingPCSelectionView = false
                }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(ProductContainerAdditionData(nil))
            })
            .sheet(isPresented: $drinkMakerData.isShowingContainerSelectionView, content: {
                ContainerListView(isDeleteDisabled: true) { container in
                    addContainer(container)
                }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(ContainerData())
            })
            .sheet(isPresented: $drinkMakerData.isShowingContainerEditingView, content: {
                DrinkMakerContainerView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(drinkMakerData.drinkMakerContainerData!)
            })
            .sheet(isPresented: $isPresentProductContainerContentView, content: {
                DrinkMakerProductContainerContentView(from: drinkMakerData.question!.version!)
                    .environmentObject(drinkMakerData)
            })
            .alert(isPresented: $isPresentAlert, content: {
                Alert(title: Text(alertType.message()))
            })
        }
    }
    
    @ViewBuilder
    var productContainer: some View {
        if let _ = drinkMakerData.productContainer {
            VStack {
                DrinkMakerProductContainerContentView()
                    .environmentObject(drinkMakerData)
                HStack {
                    Button(action: {
                        controller.startOver()
                    }, label: {
                        Text("Start Over")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    })
                }
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
                                                    .padding()
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
                                                    .padding()
                        }
                        
                    })
                }
                Section {
                    if isShowingIngredientSelectionView {
                        if let productContainer = drinkMakerData.productContainer, let ingredientSet = productContainer.ingredients as? Set<Ingredient> {
                            IngredientAmountUnitSelectionView(ingredients: Array(ingredientSet)) { ingredient, unit, amount in
                                addToProductContainer(ingredient, unit: unit, amount: amount)
                            }
                        }
                        
                    }
                    if isShowingOperationSelectionView {
                        if let productContainer = drinkMakerData.productContainer, let operationSet = productContainer.operations as? Set<Operation> {
                            let operations = Array(operationSet)
                            if operations.isEmpty {
                                Text("Empty")
                            } else {
                                List {
                                    ForEach(operations) { operation in
                                        Button(action: {
                                            addToProductContainer(operation)
                                        }, label: {
                                            Text(operation.name ?? "Error item")
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
            .padding()
        } else {
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                VStack {
                    Text("Click to select a product container")
                        .foregroundColor(.gray)
                }
            }
            .gesture(TapGesture().onEnded({ _ in
                drinkMakerData.isShowingPCSelectionView = true
            }))
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
        } else if drinkMakerData.mode == .Exam {
            HStack {
                Text("\(drinkMakerData.question?.version?.product?.name ?? "Error item") - \(drinkMakerData.question?.version?.name ?? "Error item")")
                    .font(.title2)
                    .bold()
                Spacer()
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
    var containList: some View {
        if drinkMakerData.histories.isEmpty {
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                VStack {
                    Text("Click to select a container")
                        .foregroundColor(.gray)
                }
            }
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 70, alignment: .topLeading)
            .gesture(TapGesture().onEnded({ _ in
                minimizedExtendedIOView()
                drinkMakerData.isShowingContainerSelectionView = true
            }))
        } else {
            ZStack {
                Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                List {
                    ForEach(drinkMakerData.histories) { history in
                        VStack {
                            VStack {
                                Text(history.container?.name ?? "Error type")
                                if let steps = history.steps as? Set<Step> {
                                    List {
                                        ForEach(Array(steps)) { step in
                                            Text(step.name ?? "Error item")
                                        }
                                    }
                                }
                            }
                            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 100, alignment: .topLeading)
                            .gesture(TapGesture().onEnded({ _ in
                                minimizedExtendedIOView()
                                drinkMakerData.set(history)
                            }))
                            HStack {
                                Spacer()
                                Text("Pour")
                                    .foregroundColor(.red)
                                    .gesture(TapGesture().onEnded({ _ in
                                        pour(history)
                                    }))
                            }
                        }
                    }
                }
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
    
    func addContainer(_ container: Container) {
        let history = History(context: viewContext)
        history.identifier = drinkMakerData.generateId()
        history.container = container
        drinkMakerData.histories.append(history)
        drinkMakerData.isShowingContainerSelectionView = false
    }
    
    func addToProductContainer(_ ingredient: Ingredient, unit: IngredientUnit, amount: IngredientUnitAmount) {
        let step = Step(context: viewContext)
        step.identifier = drinkMakerData.generateId()
        step.name = "\(amount.name ?? "Error item")\(unit.name ?? "Error item") \(ingredient.name ?? "Error item")"
        drinkMakerData.steps.append(step)
    }
    
    func addToProductContainer(_ operation: Operation) {
        let step = Step(context: viewContext)
        step.identifier = drinkMakerData.generateId()
        step.name = "\(operation.name ?? "Error item")"
        drinkMakerData.steps.append(step)
    }
    
    func pour(_ history: History) {
        if let _ = drinkMakerData.productContainer {
            let step = Step(context: viewContext)
            step.identifier = history.identifier
            step.childHistory = history
            drinkMakerData.steps.append(step)
            addContainer(history.container!)
            drinkMakerData.remove(history)
        } else {
            alertType = .productContainerIsMissing
            isPresentAlert = true
        }
    }
    
    func verifyFields() -> Bool {
        if drinkMakerData.productContainer == nil {
            alertType = .productContainerIsMissing
            isPresentAlert = true
            return false
        }
        if drinkMakerData.steps.count == 0 {
            alertType = .stepsNotEnough
            isPresentAlert = true
            return false
        }
        if drinkMakerData.mode == .Creator && drinkMakerData.version == nil {
            alertType = .versionUnspecified
            isPresentAlert = true
            return false
        }
        return true
    }
    
    func readyForGoingBack() {
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
    
    func submit() {
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
            timer.invalidate()
        }
        switch drinkMakerData.mode {
        case .Exam:
            if !controller.nextQuestion() {
                drinkMakerData.isSubmitted = true
            }
            save()
        case .Creator:
            controller.submitVersion()
            drinkMakerData.isSubmitted = true
            save()
        case .Practice:
            drinkMakerData.isSubmitted = true
        }
        
    }
    
    func save() {
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
