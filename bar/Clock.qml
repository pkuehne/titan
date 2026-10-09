import QtQuick
import Quickshell
import qs

Text {
  id: clock
  anchors.centerIn: parent
  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: Qt.formatDateTime(system.date, "HH:mm")
  SystemClock {
    id: system
    precision: SystemClock.Minutes
  }
}
