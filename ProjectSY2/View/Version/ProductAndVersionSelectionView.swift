//
//  ProductAndSeriesSelectionView.swift
//  ProjectSY2
//
//  Created by Yiyao Zhang on 2021-06-01.
//

import SwiftUI
import Combine

class ProductAndVersionData: ObservableObject {
    @Published var series: Series?
    @Published var isEditingProduct: Product? = nil
    @Published var productName: String = ""
    @Published var isEditingVersion: Version? = nil
    @Published var versionName: String = ""
    @Published var products: [Product] = []
    @Published var selectedProduct: Product? = nil
    @Published var versions: [Version] = []
    @Published var isShowingPVSelectionView = false
    @Published var warningProductIsNotSelected = false
    
    init() {
        self.series = nil
        resetEverythingExceptSeries()
    }
    
    private func resetEverythingExceptSeries() {
        products = []
        selectedProduct = nil
        versions = []
        isShowingPVSelectionView = false
        resetEditingData()
    }
    
    private func resetEditingData() {
        isEditingProduct = nil
        isEditingVersion = nil
    }
    
    func set(_ s: Series) {
        resetEverythingExceptSeries()
        self.series = s
        if let ps = series?.products as? Set<Product> {
            products = ps.sorted(by: DrinkMakerComparator.compare(_:_:))
        }
        if products.count > 0 {
            set(products[0])
        }
        isShowingPVSelectionView = true
    }
    
    func set(_ pd: Product?) {
        selectedProduct = pd
        resetEditingData()
        if let pd = pd, let versionSet = pd.versions as? Set<Version> {
            self.versions = versionSet.sorted(by: DrinkMakerComparator.compare(_:_:))
        } else {
            self.versions = []
        }
    }
    
    func setFocusOnProduct(_ product: Product?) {
        if let product = product {
            productName = product.name ?? "Empty Name"
        }
        isEditingProduct = product
    }
    
    func setFocusOnVersion(_ version: Version?) {
        if let version = version {
            versionName = version.name ?? "Empty Name"
        }
        isEditingVersion = version
    }
    
    func addProduct(_ product: Product) {
        series?.addToProducts(product)
        products.append(product)
        setFocusOnProduct(product)
    }
    
    func addVersion(_ version: Version) {
        if selectedProduct == nil {
            warningProductIsNotSelected = true
            return
        }
        selectedProduct!.addToVersions(version)
        versions.append(version)
        setFocusOnVersion(version)
    }
}

struct ProductAndVersionSelectionView: View {
    var showTitle = false
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var data: ProductAndVersionData
    var selected: ((Product, Version) -> Void)?
    
    var body: some View {
        VStack {
            title
            HStack {
                VStack {
                    HStack {
                        Text("Product List")
                        Spacer()
                        Button(action: {
                            addProduct()
                        }, label: {
                            Image(systemName: "plus.square.fill")
                                .font(.title2)
                        })
                    }
                    productList
                    Spacer()
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    HStack {
                        Text("Version List")
                        Spacer()
                        Button(action: {
                            addVersion()
                        }, label: {
                            Image(systemName: "plus.square")
                                .font(.title2)
                        })
                    }
                    versionList
                    Spacer()
                }
            }
        }
        .padding()
        .alert(isPresented: $data.warningProductIsNotSelected, content: {
            Alert(title: Text("Please select a product first."))
        })
    }
    
    @ViewBuilder
    var title: some View {
        if showTitle {
            HStack {
                Text(data.series?.name ?? "Product and Series")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var productList: some View {
        if data.products.isEmpty {
            HStack {
                Text("Empty...")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            List {
                ForEach(data.products) { product in
                    if product == data.isEditingProduct {
                        HStack {
                            Image(systemName: "pencil")
                            TextField("Name of the product", text: $data.productName) { _ in} onCommit: {
                                saveProduct()
                            }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
                                .gesture(TapGesture().onEnded({ _ in
                                    saveProduct()
                                }))
                            Image(systemName: "clear")
                                .foregroundColor(.red)
                                .gesture(TapGesture().onEnded({ _ in
                                    data.setFocusOnProduct(nil)
                                }))
                        }
                    } else if let selected = data.selectedProduct, product == selected {
                        HStack {
                            HStack {
                                Spacer()
                                Text(product.name ?? "Error item")
                                    .bold()
                                Image(systemName: "checkmark")
                                Spacer()
                            }
                            .gesture(TapGesture().onEnded({ _ in
                                data.set(nil)
                            }))
                            Spacer()
                        }
                    } else {
                        HStack {
                            HStack {
                                Spacer()
                                Text(product.name!)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                data.set(product)
                            }
                            .onLongPressGesture {
                                data.setFocusOnProduct(product)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var versionList: some View {
        if data.selectedProduct == nil {
            VStack {
                Spacer()
                Text("Please select a product")
                    .foregroundColor(.gray)
                    .bold()
                Spacer()
            }
        } else if data.versions.isEmpty {
            HStack {
                Text("Empty...")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            List {
                ForEach(data.versions) { version in
                    if version == data.isEditingVersion {
                        HStack {
                            Image(systemName: "pencil")
                            TextField("Name of the version", text: $data.versionName) { _ in} onCommit: {
                                saveVersion()
                            }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
                                .gesture(TapGesture().onEnded({ _ in
                                    saveVersion()
                                }))
                            Image(systemName: "clear")
                                .foregroundColor(.red)
                                .gesture(TapGesture().onEnded({ _ in
                                    data.setFocusOnVersion(nil)
                                }))
                        }
                    } else {
                        HStack {
                            HStack {
                                Spacer()
                                Text(version.name!)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let selected = selected {
                                    selected(data.selectedProduct!, version)
                                } else {
                                    data.setFocusOnVersion(version)
                                }
                            }
                            .onLongPressGesture {
                                data.setFocusOnVersion(version)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func verifyProductNameField() -> Bool {
        return data.productName != ""
    }
    
    private func verifyVersionNameField() -> Bool {
        return data.versionName != ""
    }
    
    private func addProduct() {
        let product = Product(context: viewContext)
        product.name = "NewProduct"
        data.addProduct(product)
    }
    
    private func saveProduct() {
        if !verifyProductNameField() {
            return
        }
        if let product = data.isEditingProduct {
            product.name = data.productName
            save()
            data.setFocusOnProduct(nil)
        }
    }
    
    private func addVersion() {
        let version = Version(context: viewContext)
        version.name = "NewVersion"
        data.addVersion(version)
    }
    
    private func saveVersion() {
        if !verifyVersionNameField() {
            return
        }
        if let version = data.isEditingVersion {
            version.name = data.versionName
            save()
            data.setFocusOnVersion(nil)
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
