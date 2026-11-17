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
    anchors { top: true; right: true; bottom: true }
    margins { top: 44; right: 8; bottom: 8 }
    implicitWidth: 420
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notification-center"

    Rectangle {
        anchors.fill: parent
        radius: Services.Theme.radius
        color: Services.Theme.panelBg
        border.color: Services.Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Notifications & Quick Settings"; color: Services.Theme.fg; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
                Button { text: "Clear"; onClicked: Services.NotificationsModel.clear() }
                Button { text: "Close"; onClicked: root.closeRequested() }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 110
                radius: Services.Theme.radiusSmall
                color: Services.Theme.cardBg
                border.color: Services.Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 10
                    Text { text: "Media player (MPRIS)"; color: Services.Theme.accent; font.bold: true }
                    Text { text: "Now playing info, artwork, play/pause/prev/next to be bound to Quickshell.Services.Mpris active player."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }
                }
            }

            Text { text: "History"; color: Services.Theme.fg; font.bold: true }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: Services.NotificationsModel.items
                delegate: Rectangle {
                    width: ListView.view ? ListView.view.width : 380
                    implicitHeight: content.implicitHeight + 16
                    radius: Services.Theme.radiusSmall
                    color: Services.Theme.cardBg
                    border.color: Services.Theme.border
                    ColumnLayout {
                        id: content
                        anchors.fill: parent; anchors.margins: 10
                        Text { text: (modelData.appName || "App") + " • " + (modelData.time || ""); color: Services.Theme.dim; font.pixelSize: 11 }
                        Text { text: modelData.summary || ""; color: Services.Theme.fg; font.bold: true; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Text { text: modelData.body || ""; color: Services.Theme.fg; wrapMode: Text.Wrap; Layout.fillWidth: true; visible: text.length > 0 }
                    }
                }
                Label { anchors.centerIn: parent; visible: !parent.count; text: "No notifications"; color: Services.Theme.dim }
            }
        }
    }
}
