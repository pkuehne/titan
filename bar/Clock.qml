import QtQuick
import Quickshell
import qs

Text {
  id: clock
  anchors.centerIn: parent
  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: Qt.formatDateTime(new Date(), "HH:mm:ss")
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      clock.text = Qt.formatDateTime(new Date(), "HH:mm:ss")
    }
  }
}
