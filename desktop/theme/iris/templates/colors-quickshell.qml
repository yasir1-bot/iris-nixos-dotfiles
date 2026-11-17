pragma Singleton
import QtQuick

// Iris-generated Quickshell theme tokens (rendered by Iris custom template).
// Import/use from shell components as Theme.* after ensuring this file is in QML import path
// or copied to the shell config directory.
QtObject {
    // Core palette
    readonly property color bg: "{bg}"
    readonly property color fg: "{fg}"
    readonly property color accent: "{accent}"
    readonly property color surface: "{surface}"
    readonly property color dim: "{dim}"
    readonly property color red: "{red}"
    readonly property color green: "{green}"
    readonly property color yellow: "{yellow}"
    readonly property color blue: "{color4}"
    readonly property color magenta: "{color5}"
    readonly property color cyan: "{color6}"

    // Derived UI tokens (tune alpha/usage in components)
    readonly property color panelBg: Qt.rgba(bg.r, bg.g, bg.b, 0.82)
    readonly property color cardBg: Qt.rgba(surface.r, surface.g, surface.b, 0.78)
    readonly property color border: Qt.rgba(fg.r, fg.g, fg.b, 0.12)
    readonly property color hover: Qt.rgba(accent.r, accent.g, accent.b, 0.16)
    readonly property color active: Qt.rgba(accent.r, accent.g, accent.b, 0.28)

    // Typography/shape hints
    readonly property int radius: 14
    readonly property int radiusSmall: 10
    readonly property int spacing: 10
    readonly property int animationMs: 220
}
