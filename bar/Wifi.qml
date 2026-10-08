import QtQuick
import Quickshell
import Quickshell.Networking
import qs

Text {
  id: root
  readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
  readonly property var network: device?.networks.values.find(n => n.connected) ?? null

  anchors.right: parent.right
  anchors.rightMargin: 12
  anchors.verticalCenter: parent.verticalCenter
  color: network ? Theme.fg : Theme.dim
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: {
    if (!Networking.wifiEnabled) return "󰤮"
    if (!network) return "󰤯"
    const bars = ["󰤟", "󰤢", "󰤥", "󰤨"]
    return bars[Math.min(3, Math.floor(network.signalStrength * 4))]
  }

  property bool open: false

  MouseArea {
    anchors.fill: parent
    onClicked: root.open = !root.open
  }

  WifiPanel {
    visible: root.open
    network: root.network
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
