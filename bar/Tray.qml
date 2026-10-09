import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
  spacing: 8

  Repeater {
    model: SystemTray.items

    IconImage {
      id: icon
      required property var modelData
      implicitSize: 18
      source: modelData.icon

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => {
          if (mouse.button === Qt.MiddleButton) {
            icon.modelData.secondaryActivate()
          } else if (mouse.button === Qt.RightButton || icon.modelData.onlyMenu) {
            if (!icon.modelData.hasMenu) return
            const pos = icon.mapToItem(null, 0, icon.height)
            icon.modelData.display(QsWindow.window, pos.x, pos.y)
          } else {
            icon.modelData.activate()
          }
        }
      }
    }
  }
}
