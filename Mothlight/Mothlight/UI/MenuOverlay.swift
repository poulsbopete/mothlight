import SwiftUI

struct MenuOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var purchases = PurchaseManager.shared
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(spacing: 6) {
                Text("Mothlight")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                Text("Flap through the moonlit pines")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.75))
            }
            Button(action: viewModel.startFromMenu) {
                Text("Play")
                    .font(.title2.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(MothlightPrimaryButtonStyle())
            .accessibilityHint("Starts a new run")

            if !purchases.hasRemovedAds {
                VStack(spacing: 10) {
                    Button {
                        Task { await purchases.purchaseRemoveAds() }
                    } label: {
                        Text(purchaseTitle)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(MothlightSecondaryButtonStyle())
                    .disabled(purchases.isPurchasing)

                    Button("Restore Purchases") {
                        Task { await purchases.restorePurchases() }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                }
            }

            Text("Best \(viewModel.highScore)")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    private var purchaseTitle: String {
        if let price = purchases.removeAdsPrice {
            return "Remove Ads — \(price)"
        }
        return "Remove Ads"
    }
}

struct MothlightPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color(red: 0.08, green: 0.1, blue: 0.18))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.78, green: 0.95, blue: 0.62))
                    .opacity(configuration.isPressed ? 0.85 : 1)
            )
    }
}

struct MothlightSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.35), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(configuration.isPressed ? 0.1 : 0.06))
                    )
            )
    }
}
