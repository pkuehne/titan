import QtQuick
import Quickshell
import qs

Text {
  id: root
  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: "󰐥"

  property bool open: false

  MouseArea {
    anchors.fill: parent
    onClicked: root.open = !root.open
  }

  PowerPanel {
    visible: root.open
    onVisibleChanged: root.open = visible
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
