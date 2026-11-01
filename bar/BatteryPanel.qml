import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

PopupWindow {
  id: panel
  required property string icon
  readonly property var device: UPower.displayDevice
  readonly property var battery: UPower.devices.values.find(d => d.isLaptopBattery) ?? null
  readonly property real remaining: UPower.onBattery ? device.timeToEmpty : device.timeToFull

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

      Detail {
        // Charge level
        icon: panel.icon
        label: `${Math.round(panel.device.percentage * 100)}%`
        tint: panel.device.percentage >= 0.6 ? Theme.green : panel.device.percentage >= 0.3 ? Theme.yellow : Theme.red
      }
      Detail {
        // Charging state
        icon: UPower.onBattery ? "󰚦" : "󰚥"
        label: UPowerDeviceState.toString(panel.device.state)
        tint: Theme.dim
      }
      Detail {
        // Time until empty or full
        visible: panel.remaining > 0
        icon: "󰅐"
        label: `${Math.floor(panel.remaining / 3600)}h ${Math.floor(panel.remaining % 3600 / 60)}m until ${UPower.onBattery ? "empty" : "full"}`
        tint: Theme.dim
      }
      Detail {
        // Battery health, as capacity relative to design
        visible: panel.battery?.healthSupported ?? false
        icon: "󰗶"
        label: `${Math.round(panel.battery?.healthPercentage ?? 0)}% health`
        tint: panel.battery?.healthPercentage >= 80 ? Theme.green : panel.battery?.healthPercentage >= 60 ? Theme.yellow : Theme.red
      }
    }
  }
}
