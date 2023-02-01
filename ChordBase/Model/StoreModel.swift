//
//  StoreModel.swift
//  ChordBase
//
//  Created by Lindar Olostur on 19.08.2022.
//

import StoreKit
import Foundation
import SwiftUI

@MainActor class ViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var  purchasedIds: [String] = []

    func fetchProducts() {
        Task {
            do {
                let products = try await Product.products(for: ["buyMeCoffee", "buyMePizza", "buyMeDrink", "fullEditor"])
                DispatchQueue.main.async {
                    self.products = products
                }
                for product in products {
                    await isPurchased(product: product)
                }
//                if let product = products.first {// only FIRST!?
//                    await isPurchased(product: product)
//                }
            } catch {
                print(error)
            }
        }
    }
    
    func isPurchased(product: Product) async {
        guard let state = await product.currentEntitlement else {return}
        switch state {
        case .verified(let transaction):
            DispatchQueue.main.async {
                self.purchasedIds.append(transaction.productID)
                print(self.purchasedIds)
            }
        case .unverified(_, _):
            break
        }
        
    }
    
    func purchase(lot: String) {
        Task {
            guard let product = products.first(where: {$0.id == lot}) else { return }
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(_):
                        DispatchQueue.main.async {
                            self.products = self.products
                        }
                    case .unverified(_, _):
                        break
                    }
                case .userCancelled:
                    break
                case .pending:
                    break
                @unknown default:
                    break
                }
            } catch {
                print(error)
            }
        }
    }
}
