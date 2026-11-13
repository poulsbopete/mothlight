import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published private(set) var hasRemovedAds = false
    @Published private(set) var removeAdsPrice: String?
    @Published private(set) var isPurchasing = false
    @Published var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { await listenForTransactions() }
        Task { await refreshProductsAndEntitlements() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refreshProductsAndEntitlements() async {
        do {
            let products = try await Product.products(for: [GameConfig.removeAdsProductID])
            if let product = products.first {
                removeAdsPrice = product.displayPrice
            }
            try await syncEntitlements()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func purchaseRemoveAds() async {
        guard !hasRemovedAds else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let products = try await Product.products(for: [GameConfig.removeAdsProductID])
            guard let product = products.first else {
                lastErrorMessage = "Remove Ads product not found. Check App Store Connect and the StoreKit config file."
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                try await syncEntitlements()
                AdCoordinator.shared.setAdsRemoved(hasRemovedAds)
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            try await syncEntitlements()
            AdCoordinator.shared.setAdsRemoved(hasRemovedAds)
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func syncEntitlements() async throws {
        var removed = false
        for await result in Transaction.currentEntitlements {
            let transaction = try checkVerified(result)
            if transaction.productID == GameConfig.removeAdsProductID {
                removed = true
            }
        }
        hasRemovedAds = removed
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await transaction.finish()
                try await syncEntitlements()
                AdCoordinator.shared.setAdsRemoved(hasRemovedAds)
            } catch {
                lastErrorMessage = error.localizedDescription
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
    }
}
