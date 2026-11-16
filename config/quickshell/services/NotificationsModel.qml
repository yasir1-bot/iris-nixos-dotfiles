pragma Singleton
import QtQuick

// Simple in-memory notification history model (Noctalia-inspired: popup stream + history).
// Extend with persistence, grouping, DND, and action replay as needed.
QtObject {
    id: root
    property var items: []
    property int limit: 100

    function addNotification(n) {
        var entry = {
            id: Date.now() + "-" + Math.random(),
            appName: n.appName || "",
            summary: n.summary || "",
            body: n.body || "",
            urgency: n.urgency,
            time: new Date().toLocaleTimeString(),
            raw: n
        }
        items = [entry].concat(items).slice(0, limit)
    }

    function clear() { items = [] }
    function dismiss(index) {
        if (index < 0 || index >= items.length) return;
        var copy = items.slice();
        copy.splice(index, 1);
        items = copy;
    }
}
