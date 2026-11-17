import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services" as Services

PanelWindow {
    id: root
    required property var screen
    required property bool open
    signal closeRequested()

    visible: open
    screen: root.screen
    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-settings"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.25)
        MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }

        Rectangle {
            width: Math.min(980, parent.width - 120)
            height: Math.min(700, parent.height - 120)
            anchors.centerIn: parent
            radius: Services.Theme.radius
            color: Services.Theme.panelBg
            border.color: Services.Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Desktop Settings"; color: Services.Theme.fg; font.pixelSize: 20; font.bold: true; Layout.fillWidth: true }
                    Button { text: "Close"; onClicked: root.closeRequested() }
                }

                TabBar {
                    id: tabs
                    Layout.fillWidth: true
                    TabButton { text: "Appearance" }
                    TabButton { text: "MangoWM" }
                    TabButton { text: "Shell" }
                    TabButton { text: "System" }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: tabs.currentIndex

                    // Appearance
                    ScrollView { ColumnLayout {
                        width: parent.width; spacing: 10
                        Label { text: "Theme (Iris)"; color: Services.Theme.accent; font.bold: true }
                        Text { text: "Wallpaper, dark/light/auto, and glass mode. Applying theme should run Iris and propagate generated outputs."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        TextField { placeholderText: "Wallpaper path"; Layout.fillWidth: true }
                        RowLayout { Button { text: "Apply Iris Theme" } Button { text: "Light" } Button { text: "Dark" } Button { text: "Auto" } }
                    }}

                    // MangoWM
                    ScrollView { ColumnLayout {
                        width: parent.width; spacing: 10
                        Label { text: "MangoWC / Window Manager"; color: Services.Theme.accent; font.bold: true }
                        Text { text: "Expose gaps, borders, animations, layouts, tags/workspaces, floating behavior, and keybindings where supported. Persist to dedicated config fragment and reload via mmsg."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Label { text: "Infinite desktop: requested; no native upstream MangoWC support found (see docs/upstream-research.md)."; color: Services.Theme.yellow; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }}

                    // Shell
                    ScrollView { ColumnLayout {
                        width: parent.width; spacing: 10
                        Label { text: "Quickshell"; color: Services.Theme.accent; font.bold: true }
                        Text { text: "Bar, launcher, notifications, control center, widgets, animation and layout preferences."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }}

                    // System / rebuild
                    ScrollView { ColumnLayout {
                        width: parent.width; spacing: 10
                        Label { text: "Declarative Apply"; color: Services.Theme.accent; font.bold: true }
                        Text { text: "Saves graphical settings to desktop/settings/settings.json (or repo-managed target), validates inputs, and can trigger a controlled NixOS rebuild. Must not execute arbitrary commands from UI input."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        TextArea { Layout.fillWidth: true; implicitHeight: 120; readOnly: true; text: "Implementation notes:\n- Write atomically and validate schema/values\n- Use a fixed allowlisted rebuild command (e.g. scripts/apply-settings.sh -> nixos-rebuild switch --flake <trusted-path>#desktop)\n- Consider polkit/sudoers rule for least privilege\n- Show success/failure logs and preserve rollback options" }
                        RowLayout {
                            Button { text: "Save Settings" }
                            Button { text: "Save + Rebuild (Safe)" }
                        }
                    }}
                }
            }
        }
    }
}
