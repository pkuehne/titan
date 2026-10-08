import QtQuick
import Quickshell
import qs

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: 32
  color: Theme.bg

  Clock {}
  Wifi {}
}
