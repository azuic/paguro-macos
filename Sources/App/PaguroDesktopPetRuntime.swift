import Combine
import Foundation

@MainActor
final class PaguroDesktopPetRuntime: ObservableObject {
    @Published var pose: PaguroSpritePose = .idle
    @Published var direction: PaguroSpriteDirection = .left
    @Published var expression: PaguroSpriteExpression = .neutral
    @Published var isBlinking = false
}
