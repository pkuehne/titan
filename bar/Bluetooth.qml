import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs

Text {
  id: root
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property bool connected: adapter?.devices.values.some(d => d.connected) ?? false

  color: connected ? Theme.fg : Theme.dim
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: !adapter?.enabled ? "󰂲" : connected ? "󰂱" : "󰂯"

  property bool open: false

  MouseArea {
    anchors.fill: parent
    onClicked: root.open = !root.open
  }

  BluetoothPanel {
    visible: root.open
    adapter: root.adapter
    onVisibleChanged: root.open = visible
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
