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
    @Published var nestedHistories: [History] = []
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
        nestedHistories = []
        histories = []
        mode = .Creator
        isLoading = false
        isSubmitted = false
        isDrinkMaking = false
        isShowingPCSelectionView = false
        isShowingContainerSelectionView = false
        isShowingContainerEditingView = false
        drinkMakerContainerData = nil
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
        } else {
            VStack {
                VStack {
                    HStack {
                        Text("DrinkMaker™")
                            .font(.title)
                            .gesture(TapGesture().onEnded({ _ in
                                landingViewData.isShowingMainMenu = true
                            }))
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
                HStack {
                    Text("Preparation Zone")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding()
                containList
                Spacer()
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
            .sheet(isPresented: $isShowingIngredientSelectionView, content: {
                IngredientAmountUnitSelectionView { ingredient, unit, amount in
                    addToProductContainer(ingredient, unit: unit, amount: amount)
                    isShowingIngredientSelectionView = false
                }
            })
            .sheet(isPresented: $isShowingOperationSelectionView, content: {
                OperationListView(isDeleteDisabled: true) { operation in
                    addToProductContainer(operation)
                }
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(OperationData())
            })
            .sheet(isPresented: $isPresentProductContainerContentView, content: {
                DrinkMakerProductContainerContentView(from: drinkMakerData.question!.version!)
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
                List {
                    ForEach(drinkMakerData.steps) { step in
                        if let name = step.name {
                            Text(name)
                        } else {
                            DrinkMakerStepsView(isShowingDetail: isShowingStepsDetail)
                                .environmentObject(DrinkMakerStepsData(drinkMakerData.nestedHistories[Int(step.index)]))
                        }
                    }
                }
                .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 150, alignment: .topLeading)
                HStack {
                    Spacer()
                    Toggle(isOn: $isShowingStepsDetail) {
                        if isShowingStepsDetail {
                            Text("Show Detail")
                        } else {
                            Text("Hide Detail")
                        }
                    }
                    Spacer()
                }
                HStack {
                    Button("Ingredients...") {
                        isShowingIngredientSelectionView = true
                    }
                    Spacer()
                    Button("Operations...") {
                        isShowingOperationSelectionView = true
                    }
                }
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
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 70, alignment: .topLeading)
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
                            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 50, idealHeight: 70, maxHeight: 200, alignment: .topLeading)
                            .gesture(TapGesture().onEnded({ _ in
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
    
    func addContainer(_ container: Container) {
        let history = History(context: viewContext)
        history.container = container
        drinkMakerData.histories.append(history)
        drinkMakerData.isShowingContainerSelectionView = false
    }
    
    func addToProductContainer(_ ingredient: Ingredient, unit: IngredientUnit, amount: IngredientUnitAmount) {
        let step = Step(context: viewContext)
        step.name = "\(amount.name ?? "Error item")\(unit.name ?? "Error item") \(ingredient.name ?? "Error item")"
        drinkMakerData.steps.append(step)
    }
    
    func addToProductContainer(_ operation: Operation) {
        let step = Step(context: viewContext)
        step.name = "\(operation.name ?? "Error item")"
        drinkMakerData.steps.append(step)
    }
    
    func pour(_ history: History) {
        if let _ = drinkMakerData.productContainer {
            let step = Step(context: viewContext)
            step.index = Int32(drinkMakerData.nestedHistories.count)
            drinkMakerData.nestedHistories.append(history)
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
