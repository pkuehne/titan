import QtQuick
import Quickshell
import qs

PopupWindow {
  id: panel

  grabFocus: true

  implicitWidth: actions.implicitWidth + 32
  implicitHeight: actions.implicitHeight + 24
  color: "transparent"

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    Column {
      id: actions
      anchors.centerIn: parent
      spacing: 6

      Repeater {
        model: [
          ["󰒲", "Hibernate", "hibernate", Theme.blue],
          ["󰜉", "Restart", "reboot", Theme.yellow],
          ["󰐥", "Shut down", "poweroff", Theme.red]
        ]

        WifiPanel.Detail {
          id: action
          required property var modelData
          icon: modelData[0]
          label: modelData[1]
          tint: modelData[3]

          TapHandler {
            onTapped: {
              panel.visible = false
              Quickshell.execDetached(["systemctl", action.modelData[2]])
            }
          }
          HoverHandler {
            cursorShape: Qt.PointingHandCursor
          }
        }
      }
    }
  }
}
