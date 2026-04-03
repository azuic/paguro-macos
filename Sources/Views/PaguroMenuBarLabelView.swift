import SwiftUI

struct PaguroMenuBarLabelView: View {
    let pet: PaguroPet

    var body: some View {
        Label {
            Text("Pg")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        } icon: {
            Image(systemName: symbolName)
                .font(.system(size: 11, weight: .semibold))
        }
        .labelStyle(.titleAndIcon)
        .accessibilityLabel("\(pet.provider.displayName) Paguro")
    }

    private var symbolName: String {
        switch pet.mood {
        case .charged:
            return "sparkles"
        case .hungry:
            return "exclamationmark.circle.fill"
        case .sleepy:
            return "moon.fill"
        case .lively:
            return "bolt.circle.fill"
        case .calm:
            return "circle.fill"
        }
    }
}
