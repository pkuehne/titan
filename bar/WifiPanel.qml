import QtQuick
import Quickshell
import Quickshell.Networking
import qs

PopupWindow {
  id: panel
  required property var network
  readonly property real strength: network?.signalStrength ?? 0

  implicitWidth: details.implicitWidth + 32
  implicitHeight: details.implicitHeight + 24
  color: "transparent"

  component Detail: Row {
    property alias icon: glyph.text
    property alias label: label.text
    property color tint: Theme.fg
    spacing: 10

    Text {
      id: glyph
      width: 16
      color: parent.tint
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
    Text {
      id: label
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }

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
        icon: panel.network ? "󰖩" : "󰖪"
        label: panel.network?.name ?? "Disconnected"
        tint: panel.network ? Theme.blue : Theme.dim
      }
      Detail {
        visible: !!panel.network
        icon: "󰒢"
        label: `${Math.round(panel.strength * 100)}%`
        tint: panel.strength >= 0.6 ? Theme.green : panel.strength >= 0.3 ? Theme.yellow : Theme.red
      }
      Detail {
        visible: !!panel.network
        icon: panel.network?.security === WifiSecurityType.Open ? "󰌿" : "󰌾"
        label: WifiSecurityType.toString(panel.network?.security ?? WifiSecurityType.Unknown)
        tint: Theme.dim
      }
    }
  }
}
