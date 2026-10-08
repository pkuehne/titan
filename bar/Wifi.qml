import QtQuick
import Quickshell.Networking
import qs

Text {
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
}
