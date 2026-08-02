import SwiftUI

struct VaultTheme {
    let primary: Color
    let accent: Color

    static let standard = VaultTheme(
        primary: Color("AppPrimary"),
        accent: Color("AppAccent")
    )
}

private struct VaultThemeKey: EnvironmentKey {
    static let defaultValue = VaultTheme.standard
}

extension EnvironmentValues {
    var vaultTheme: VaultTheme {
        get { self[VaultThemeKey.self] }
        set { self[VaultThemeKey.self] = newValue }
    }
}
