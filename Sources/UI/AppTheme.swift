import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.97, green: 0.94, blue: 0.90)
    static let surface = Color(red: 0.99, green: 0.97, blue: 0.95)
    static let soft = Color(red: 0.94, green: 0.90, blue: 0.84)
    static let primary = Color(red: 0.70, green: 0.53, blue: 0.33)
    static let deep = Color(red: 0.30, green: 0.22, blue: 0.15)
    static let muted = Color(red: 0.49, green: 0.42, blue: 0.35)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}

extension View {
    func appCard() -> some View {
        modifier(CardModifier())
    }
}
