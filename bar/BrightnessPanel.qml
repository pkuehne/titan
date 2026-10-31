import QtQuick
import Quickshell
import qs

PopupWindow {
  id: panel
  required property string icon
  required property real level
  readonly property alias hovered: hover.hovered
  signal moved(real value)

  implicitWidth: row.implicitWidth + 32
  implicitHeight: row.implicitHeight + 24
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    HoverHandler {
      id: hover
    }

    Row {
      id: row
      anchors.centerIn: parent
      spacing: 8

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        text: panel.icon
        color: Theme.yellow
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      LevelSlider {
        anchors.verticalCenter: parent.verticalCenter
        value: panel.level
        fill: Theme.yellow
        onMoved: panel.moved(value)
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: maxLabel.width
        horizontalAlignment: Text.AlignRight
        text: `${Math.round(panel.level * 100)}%`
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize

        TextMetrics {
          id: maxLabel
          text: "100%"
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }
      }
    }
  }
}
