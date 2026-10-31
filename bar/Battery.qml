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
  readonly property real percentage: UPower.displayDevice.percentage
  readonly property var lowThresholds: [0.05, 0.1]
  property real warnedAt: 1

  function warnIfLow() {
    if (!UPower.onBattery) {
      warnedAt = 1
      return
    }
    const threshold = lowThresholds.find(t => percentage <= t && t < warnedAt)
    if (threshold === undefined) return
    warnedAt = threshold
    const urgency = threshold === lowThresholds[0] ? "critical" : "normal"
    Quickshell.execDetached(["notify-send", "-u", urgency, "-a", "Battery", "Battery low", `${Math.round(percentage * 100)}% remaining`])
  }

  onPercentageChanged: warnIfLow()
  Component.onCompleted: warnIfLow()

  Connections {
    target: UPower

    function onOnBatteryChanged() {
      root.warnIfLow()
    }
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
