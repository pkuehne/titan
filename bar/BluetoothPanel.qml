import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs

PopupWindow {
  id: panel
  required property var adapter
  readonly property var devices: adapter?.devices.values
    .filter(d => d.paired || d.deviceName)
    .sort((a, b) => b.connected - a.connected || b.paired - a.paired || a.name.localeCompare(b.name)) ?? []
  readonly property var icons: ({
    "input-mouse": "󰍽",
    "input-keyboard": "󰌌",
    "audio-headset": "󰋋",
    "audio-headphones": "󰋋"
  })

  readonly property int sigint: 2

  onVisibleChanged: {
    if (visible) agent.running = true
    else agent.signal(sigint)
    if (!adapter?.enabled) return
    adapter.pairable = visible
    adapter.discovering = visible
  }

  Process {
    // bt-agent ignores SIGTERM and asks for confirmation on stdin
    id: agent
    command: ["bash", "-c", "exec bt-agent -c NoInputNoOutput < <(yes)"]
    Component.onDestruction: if (running) signal(panel.sigint)
  }

  grabFocus: true

  implicitWidth: details.implicitWidth + 32
  implicitHeight: details.implicitHeight + 24
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    Column {
      id: details
      anchors.centerIn: parent
      spacing: 6

      Item {
        implicitWidth: current.implicitWidth + toggle.implicitWidth + 16
        implicitHeight: current.implicitHeight
        width: Math.max(implicitWidth, parent.width)

        WifiPanel.Detail {
          id: current
          icon: panel.adapter?.enabled ? "󰂯" : "󰂲"
          label: panel.adapter ? BluetoothAdapterState.toString(panel.adapter.state) : "No adapter"
          tint: panel.adapter?.enabled ? Theme.blue : Theme.dim
        }

        WifiJoin.Glyph {
          id: toggle
          anchors.right: parent.right
          text: panel.adapter?.enabled ? "󰔡" : "󰨙"
          color: panel.adapter?.enabled ? Theme.green : Theme.dim
          active: !!panel.adapter && panel.adapter.state !== BluetoothAdapterState.Blocked
          onClicked: panel.adapter.enabled = !panel.adapter.enabled
        }
      }

      Rectangle {
        // Divider
        visible: panel.devices.length > 0
        width: parent.width
        height: 1
        color: Theme.border
      }

      Repeater {
        model: panel.devices

        Row {
          id: entry
          required property var modelData
          readonly property bool busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting
            || modelData.state === BluetoothDeviceState.Disconnecting
          spacing: 8

          Connections {
            target: entry.modelData

            function onPairedChanged() {
              if (!entry.modelData.paired) return
              entry.modelData.trusted = true
              entry.modelData.connect()
            }
          }

          WifiPanel.Detail {
            icon: panel.icons[entry.modelData.icon] ?? "󰂯"
            label: entry.modelData.name
              + (entry.modelData.batteryAvailable ? `  ${Math.round(entry.modelData.battery * 100)}%` : "")
            tint: entry.busy ? Theme.yellow : entry.modelData.connected ? Theme.blue : entry.modelData.paired ? Theme.fg : Theme.dim
          }

          WifiJoin.Glyph {
            visible: !entry.modelData.connected
            text: "󰌘"
            color: Theme.green
            active: !entry.busy
            onClicked: entry.modelData.paired ? entry.modelData.connect() : entry.modelData.pair()
          }

          WifiJoin.Glyph {
            visible: entry.modelData.connected
            text: "󰌸"
            color: Theme.yellow
            onClicked: entry.modelData.disconnect()
          }

          WifiJoin.Glyph {
            visible: entry.modelData.paired
            text: "󰆴"
            color: Theme.red
            onClicked: entry.modelData.forget()
          }
        }
      }
    }
  }
}
