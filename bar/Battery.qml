import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

Text {
  id: root
  property bool showPercentage: false
  readonly property var dischargingIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  readonly property var chargingIcons: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
  readonly property var stateIcon: {
    let iconIndex = Math.round(UPower.displayDevice.percentage * 10)
    return UPower.onBattery ? dischargingIcons[iconIndex] : chargingIcons[iconIndex]
  }

  anchors {
    right: parent.right
    rightMargin: 12
    verticalCenter: parent.verticalCenter
  }
  color: UPower.displayDevice.percentage < 0.2 ? Theme.red : Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize

  text: {
    let text = stateIcon
    if (showPercentage) {
      text += " " + Math.round(UPower.displayDevice.percentage * 100) + "%"
    }
    return text
  }

  property bool open: false

  MouseArea {
    anchors.fill: parent
    onClicked: root.open = !root.open
  }

  BatteryPanel {
    visible: root.open
    icon: root.stateIcon
    onVisibleChanged: root.open = visible
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
