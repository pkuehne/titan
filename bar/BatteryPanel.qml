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

      WifiPanel.Detail {
        // Charge level
        icon: panel.icon
        label: `${Math.round(panel.device.percentage * 100)}%`
        tint: panel.device.percentage >= 0.6 ? Theme.green : panel.device.percentage >= 0.3 ? Theme.yellow : Theme.red
      }
      WifiPanel.Detail {
        // Charging state
        icon: UPower.onBattery ? "󰚦" : "󰚥"
        label: UPowerDeviceState.toString(panel.device.state)
        tint: Theme.dim
      }
      WifiPanel.Detail {
        // Time until empty or full
        visible: panel.remaining > 0
        icon: "󰅐"
        label: `${Math.floor(panel.remaining / 3600)}h ${Math.floor(panel.remaining % 3600 / 60)}m until ${UPower.onBattery ? "empty" : "full"}`
        tint: Theme.dim
      }
      WifiPanel.Detail {
        // Battery health, as capacity relative to design
        visible: panel.battery?.healthSupported ?? false
        icon: "󰗶"
        label: `${Math.round(panel.battery?.healthPercentage ?? 0)}% health`
        tint: panel.battery?.healthPercentage >= 80 ? Theme.green : panel.battery?.healthPercentage >= 60 ? Theme.yellow : Theme.red
      }

      Rectangle {
        // Divider
        width: parent.width
        height: 1
        color: Theme.border
      }

      Row {
        // Power profile picker
        spacing: 12

        Repeater {
          model: [
            [PowerProfile.PowerSaver, "󰌪"],
            [PowerProfile.Balanced, "󰗑"],
            [PowerProfile.Performance, "󰓅"]
          ]

          WifiJoin.Glyph {
            required property var modelData
            text: modelData[1]
            color: PowerProfiles.profile === modelData[0] ? Theme.blue : Theme.dim
            active: modelData[0] !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile
            onClicked: PowerProfiles.profile = modelData[0]
          }
        }
        Text {
          text: PowerProfile.toString(PowerProfiles.profile)
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }
      }
      WifiPanel.Detail {
        // Why performance is being throttled
        visible: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
        icon: "󰀦"
        label: PerformanceDegradationReason.toString(PowerProfiles.degradationReason)
        tint: Theme.yellow
      }
    }
  }
}
