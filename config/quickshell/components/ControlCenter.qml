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
    signal openSettings()

    visible: open
    screen: root.screen
    anchors { top: true; right: true }
    margins { top: 44; right: 8 }
    implicitWidth: 380
    implicitHeight: 560
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-control-center"

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
                Text { text: "Control Center"; color: Services.Theme.fg; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
                Button { text: "Settings"; onClicked: root.openSettings() }
            }

            GroupBox {
                title: "Quick toggles"
                Layout.fillWidth: true
                GridLayout {
                    columns: 2
                    anchors.fill: parent
                    Button { text: "Wi-Fi"; Layout.fillWidth: true }
                    Button { text: "Bluetooth"; Layout.fillWidth: true }
                    Button { text: "DND"; Layout.fillWidth: true }
                    Button { text: "Night/Theme"; Layout.fillWidth: true }
                }
            }

            GroupBox {
                title: "Volume & Brightness"
                Layout.fillWidth: true
                ColumnLayout {
                    anchors.fill: parent
                    Label { text: "Volume (PipeWire/wireplumber integration)"; color: Services.Theme.dim }
                    Slider { Layout.fillWidth: true; from: 0; to: 100; value: 50 }
                    Label { text: "Brightness (brightnessctl integration)"; color: Services.Theme.dim }
                    Slider { Layout.fillWidth: true; from: 0; to: 100; value: 70 }
                }
            }

            GroupBox {
                title: "Media"
                Layout.fillWidth: true
                ColumnLayout {
                    anchors.fill: parent
                    Text { text: "MPRIS player controls: play/pause, previous, next, metadata/artwork."; color: Services.Theme.dim; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    RowLayout {
                        Button { text: "Prev" }
                        Button { text: "Play/Pause" }
                        Button { text: "Next" }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
