import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }
  implicitHeight: 32
  color: Theme.bg
  WlrLayershell.keyboardFocus: wifi.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

  Clock {}
  Wifi { id: wifi }
  Tray {
    anchors.right: wifi.left
    anchors.rightMargin: 12
    anchors.verticalCenter: parent.verticalCenter
  }
}
