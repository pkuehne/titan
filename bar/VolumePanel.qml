import QtQuick
import QtQuick.Controls
import Quickshell
import qs

PopupWindow {
  id: panel
  required property var audio
  required property string icon
  required property string label
  readonly property alias hovered: hover.hovered
  readonly property bool muted: audio?.muted ?? true

  implicitWidth: details.implicitWidth + 32
  implicitHeight: details.implicitHeight + 24
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    HoverHandler {
      id: hover
    }

    Column {
      id: details
      anchors.centerIn: parent
      spacing: 6

      WifiPanel.Detail {
        // Output device
        icon: "󰓃"
        label: panel.label
        tint: Theme.dim
      }

      Row {
        spacing: 8

        WifiJoin.Glyph {
          // Mute toggle
          width: 16
          text: panel.icon
          color: panel.muted ? Theme.dim : Theme.blue
          active: !!panel.audio
          onClicked: panel.audio.muted = !panel.audio.muted
        }

        Slider {
          id: slider
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: 160
          enabled: !!panel.audio
          value: panel.audio?.volume ?? 0
          onMoved: panel.audio.volume = value

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
              color: panel.muted ? Theme.dim : Theme.blue
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
          text: `${Math.round((panel.audio?.volume ?? 0) * 100)}%`
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
}
