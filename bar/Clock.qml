import QtQuick
import Quickshell

Text {
  id: clock
  anchors.centerIn: parent
  color: "#c0caf5"
  font.pixelSize: 14
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
