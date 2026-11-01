import QtQuick
import Quickshell
import qs
import "FanModel.js" as Model

PopupWindow {
  id: panel
  required property var fans
  required property var temps
  required property string profile
  required property var choices
  required property bool writable
  required property string error
  signal profileChosen(string name)

  grabFocus: true

  implicitWidth: details.implicitWidth + 32
  implicitHeight: details.implicitHeight + 24
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    Column {
      id: details
      anchors.centerIn: parent
      spacing: 6

      Repeater {
        model: panel.fans

        Detail {
          required property var modelData
          icon: Model.FAN_GLYPH
          label: `${modelData.label}  ${modelData.rpm > 0 ? modelData.rpm + " rpm" : "idle"}`
          tint: modelData.rpm > 0 ? Theme.blue : Theme.dim
        }
      }
      Repeater {
        model: panel.temps

        Detail {
          required property var modelData
          icon: Model.TEMP_GLYPH
          label: `${modelData.label}  ${modelData.celsius}°C`
          tint: modelData.celsius >= 80 ? Theme.red : modelData.celsius >= 60 ? Theme.yellow : Theme.dim
        }
      }

      Rectangle {
        // Divider
        width: parent.width
        height: 1
        color: Theme.border
      }

      Row {
        // Platform profile picker
        spacing: 12

        Repeater {
          model: panel.choices

          WifiJoin.Glyph {
            id: choice
            required property var modelData
            text: Model.profileIcon(choice.modelData)
            color: panel.profile === choice.modelData ? Theme.blue : Theme.dim
            active: panel.writable
            onClicked: panel.profileChosen(choice.modelData)
          }
        }
        Text {
          text: Model.profileLabel(panel.profile)
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }
      }
      Detail {
        visible: !panel.writable
        icon: "󰀦"
        label: "Read only, run just desktop"
        tint: Theme.yellow
      }
      Detail {
        visible: panel.error !== ""
        icon: "󰀦"
        label: panel.error
        tint: Theme.red
      }
    }
  }
}
