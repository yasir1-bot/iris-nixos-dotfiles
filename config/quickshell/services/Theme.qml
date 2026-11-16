pragma Singleton
import QtQuick

// Runtime theme loader.
// Preferred: Iris renders a custom template to ~/.cache/iris/colors-quickshell.qml and this file
// can be replaced/symlinked or the shell can import from a runtime path. For portability this
// singleton provides defaults and can be extended to read JSON from ~/.cache/iris/colors.json.
QtObject {
    // Fallback palette (replaced at runtime by Iris integration/watcher in a fuller implementation)
    readonly property color bg: "#1e1e2e"
    readonly property color fg: "#cdd6f4"
    readonly property color accent: "#89b4fa"
    readonly property color surface: "#313244"
    readonly property color dim: "#6c7086"
    readonly property color red: "#f38ba8"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color blue: "#89b4fa"
    readonly property color magenta: "#cba6f7"
    readonly property color cyan: "#94e2d5"

    readonly property color panelBg: Qt.rgba(bg.r, bg.g, bg.b, 0.82)
    readonly property color cardBg: Qt.rgba(surface.r, surface.g, surface.b, 0.78)
    readonly property color border: Qt.rgba(fg.r, fg.g, fg.b, 0.12)
    readonly property color hover: Qt.rgba(accent.r, accent.g, accent.b, 0.16)
    readonly property color active: Qt.rgba(accent.r, accent.g, accent.b, 0.28)

    readonly property int radius: 14
    readonly property int radiusSmall: 10
    readonly property int spacing: 10
    readonly property int animationMs: 220
}
