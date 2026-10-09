import QtQuick
import Quickshell.Services.UPower
import qs

Text {
  property bool showPercentage
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
  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize

  text: stateIcon + " " + Math.round(UPower.displayDevice.percentage * 100) + "%"
}
