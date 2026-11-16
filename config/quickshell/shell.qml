import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import "components" as Components
import "services" as Services

ShellRoot {
    id: root

    // Centralized state/services for the shell (Noctalia-inspired separation: services + panels/modules)
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false
    property bool settingsOpen: false

    function toggleLauncher() { launcherOpen = !launcherOpen; if (launcherOpen) { controlCenterOpen = false; notificationCenterOpen = false; settingsOpen = false; } }
    function toggleControlCenter() { controlCenterOpen = !controlCenterOpen; if (controlCenterOpen) { launcherOpen = false; notificationCenterOpen = false; settingsOpen = false; } }
    function toggleNotificationCenter() { notificationCenterOpen = !notificationCenterOpen; if (notificationCenterOpen) { launcherOpen = false; controlCenterOpen = false; settingsOpen = false; } }
    function toggleSettings() { settingsOpen = !settingsOpen; if (settingsOpen) { launcherOpen = false; controlCenterOpen = false; notificationCenterOpen = false; } }

    // Notification daemon/server integration (history persistence/UI handled by shell components)
    NotificationServer {
        id: notificationServer
        keepOnReload: true
        onNotification: function(notification) {
            Services.NotificationsModel.addNotification(notification)
        }
    }

    // Per-screen shell surfaces
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property var modelData

            Components.Bar {
                screen: modelData
                onRequestLauncher: root.toggleLauncher()
                onRequestControlCenter: root.toggleControlCenter()
                onRequestNotificationCenter: root.toggleNotificationCenter()
                onRequestSettings: root.toggleSettings()
            }

            Components.Launcher {
                screen: modelData
                open: root.launcherOpen
                onCloseRequested: root.launcherOpen = false
            }

            Components.ControlCenter {
                screen: modelData
                open: root.controlCenterOpen
                onCloseRequested: root.controlCenterOpen = false
                onOpenSettings: root.toggleSettings()
            }

            Components.NotificationCenter {
                screen: modelData
                open: root.notificationCenterOpen
                onCloseRequested: root.notificationCenterOpen = false
            }

            Components.SettingsPanel {
                screen: modelData
                open: root.settingsOpen
                onCloseRequested: root.settingsOpen = false
            }
        }
    }
}
