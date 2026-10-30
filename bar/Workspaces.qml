import QtQuick
import Quickshell.Hyprland
import qs

Row {
  id: root
  readonly property int persistent: 5
  readonly property var ids: {
    const open = Hyprland.workspaces.values.map(w => w.id).filter(id => id > 0)
    const count = Math.max(persistent, ...open)
    return Array.from({ length: count }, (_, i) => i + 1)
  }
  spacing: Theme.iconSpacing

  Repeater {
    model: root.ids

    Text {
      id: label
      required property var modelData
      readonly property bool focused: Hyprland.focusedWorkspace?.id === modelData
      readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === modelData)
      color: focused ? Theme.fg : occupied ? Theme.blue : Theme.dim
      font.bold: focused
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      text: modelData

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${label.modelData} })`)
      }
    }
  }
}
