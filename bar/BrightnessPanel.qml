import QtQuick
import QtQuick.Controls
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

      Slider {
        id: slider
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 160
        value: panel.level
        onMoved: panel.moved(value)

        background: Rectangle {
          x: slider.leftPadding
          y: slider.topPadding + (slider.availableHeight - height) / 2
          width: slider.availableWidth
          height: 4
          radius: 2
          color: Theme.border

          Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: Theme.yellow
          }
        }

        handle: Rectangle {
          x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
          y: slider.topPadding + (slider.availableHeight - height) / 2
          implicitWidth: 12
          implicitHeight: 12
          radius: 6
          color: Theme.fg
        }
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
