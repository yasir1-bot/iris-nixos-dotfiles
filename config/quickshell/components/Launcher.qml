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
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.25)
        MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }

        Rectangle {
            width: Math.min(720, parent.width - 80)
            height: Math.min(520, parent.height - 160)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 120
            radius: Services.Theme.radius
            color: Services.Theme.panelBg
            border.color: Services.Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                TextField {
                    id: query
                    Layout.fillWidth: true
                    placeholderText: "Search applications, actions..."
                    color: Services.Theme.fg
                    placeholderTextColor: Services.Theme.dim
                    background: Rectangle { radius: Services.Theme.radiusSmall; color: Services.Theme.cardBg; border.color: Services.Theme.border }
                    onAccepted: root.closeRequested()
                    Keys.onEscapePressed: root.closeRequested()
                }

                Text { text: "Application launcher (Noctalia-inspired): app search, keyboard navigation, power actions/search providers to be wired via DesktopEntries/providers."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: ListModel {
                        ListElement { name: "Ghostty"; desc: "Terminal" }
                        ListElement { name: "Files"; desc: "File manager" }
                        ListElement { name: "Settings"; desc: "Open shell settings" }
                        ListElement { name: "Lock"; desc: "Power action" }
                        ListElement { name: "Logout"; desc: "Power action" }
                    }
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 44
                        radius: Services.Theme.radiusSmall
                        color: ListView.isCurrentItem ? Services.Theme.active : "transparent"
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 10
                            Text { text: model.name; color: Services.Theme.fg; Layout.fillWidth: true }
                            Text { text: model.desc; color: Services.Theme.dim }
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }
                    }
                }
            }
        }
    }
}
