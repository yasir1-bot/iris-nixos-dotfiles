import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services" as Services

PanelWindow {
    id: bar
    required property var screen
    signal requestLauncher()
    signal requestControlCenter()
    signal requestNotificationCenter()
    signal requestSettings()

    screen: bar.screen
    anchors { top: true; left: true; right: true }
    implicitHeight: 34
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.exclusiveZone: implicitHeight

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        radius: Services.Theme.radius
        color: Services.Theme.panelBg
        border.color: Services.Theme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: Services.Theme.spacing

            // Left: launcher + workspaces (MangoWC tag/workspace integration via IPC/mmsg can be wired here)
            RowLayout {
                spacing: 6
                Rectangle {
                    width: 28; height: 22; radius: Services.Theme.radiusSmall
                    color: maLauncher.containsMouse ? Services.Theme.hover : "transparent"
                    Text { anchors.centerIn: parent; text: "󰀻"; color: Services.Theme.accent }
                    MouseArea { id: maLauncher; anchors.fill: parent; hoverEnabled: true; onClicked: bar.requestLauncher() }
                }
                Repeater {
                    model: 9
                    delegate: Rectangle {
                        width: 18; height: 18; radius: 9
                        color: index === 0 ? Services.Theme.active : "transparent"
                        border.color: Services.Theme.border
                        Text { anchors.centerIn: parent; text: index + 1; color: Services.Theme.fg; font.pixelSize: 10 }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Center: clock/window title placeholder
            Text {
                text: Qt.formatDateTime(new Date(), "ddd MMM d  hh:mm")
                color: Services.Theme.fg
                font.pixelSize: 12
                Timer { interval: 10000; running: true; repeat: true; onTriggered: parent.text = Qt.formatDateTime(new Date(), "ddd MMM d  hh:mm") }
            }

            Item { Layout.fillWidth: true }

            // Right: status pills (media/tray/network/volume/battery/notifications/settings)
            RowLayout {
                spacing: 6
                Rectangle { width: 26; height: 22; radius: Services.Theme.radiusSmall; color: "transparent"; Text { anchors.centerIn: parent; text: "󰝚"; color: Services.Theme.fg } }
                Rectangle {
                    width: 26; height: 22; radius: Services.Theme.radiusSmall
                    color: maNotif.containsMouse ? Services.Theme.hover : "transparent"
                    Text { anchors.centerIn: parent; text: "󰂚"; color: Services.Theme.fg }
                    MouseArea { id: maNotif; anchors.fill: parent; hoverEnabled: true; onClicked: bar.requestNotificationCenter() }
                }
                Rectangle {
                    width: 26; height: 22; radius: Services.Theme.radiusSmall
                    color: maCC.containsMouse ? Services.Theme.hover : "transparent"
                    Text { anchors.centerIn: parent; text: "󰒓"; color: Services.Theme.accent }
                    MouseArea { id: maCC; anchors.fill: parent; hoverEnabled: true; onClicked: bar.requestControlCenter() }
                }
            }
        }
    }
}
