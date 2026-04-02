import SwiftUI

struct PaguroMenuBarLabelView: View {
    let pet: PaguroPet

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottomLeading) {
                Circle()
                    .fill(.primary)
                    .frame(width: 12, height: 12)
                    .offset(x: 1, y: -1)

                Capsule()
                    .fill(.primary)
                    .frame(width: 10, height: 6)
                    .offset(x: -4, y: 4)

                Circle()
                    .fill(.primary)
                    .frame(width: 3, height: 3)
                    .offset(x: 0, y: 2)

                Circle()
                    .fill(.primary)
                    .frame(width: 1.5, height: 1.5)
                    .offset(x: -2, y: 3)

                Circle()
                    .fill(.primary)
                    .frame(width: 1.5, height: 1.5)
                    .offset(x: 2, y: 3)
            }
            .frame(width: 16, height: 16)

            if pet.mood == .charged {
                Image(systemName: "sparkle")
                    .font(.system(size: 7, weight: .bold))
                    .offset(x: 3, y: -2)
            } else if pet.mood == .hungry {
                Circle()
                    .fill(.primary)
                    .frame(width: 3, height: 3)
                    .offset(x: 0, y: 0)
            }
        }
        .frame(width: 20, height: 16)
        .accessibilityLabel("\(pet.provider.displayName) Paguro")
    }
}
