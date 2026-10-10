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
  Tray {
    id: tray
    anchors.right: bluetooth.left
    anchors.rightMargin: Theme.iconSpacing
    anchors.verticalCenter: parent.verticalCenter
  }
  Bluetooth {
    id: bluetooth
    anchors {
      right: wifi.left
      rightMargin: Theme.iconSpacing
      verticalCenter: parent.verticalCenter
    }
  }
  Wifi {
    id: wifi
    anchors {
      right: battery.left
      rightMargin: Theme.iconSpacing
      verticalCenter: parent.verticalCenter
    }
  }
  Battery {
    id: battery
    anchors {
      right: power.left
      rightMargin: Theme.iconSpacing
      verticalCenter: parent.verticalCenter
    }
  }
  Power {
    id: power
    anchors {
      right: parent.right
      rightMargin: Theme.iconSpacing
      verticalCenter: parent.verticalCenter
    }
  }
}
