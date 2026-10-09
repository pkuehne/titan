pragma Singleton

import QtQuick
import Quickshell

Singleton {
  readonly property string fontFamily: "FiraCode Nerd Font Propo"
  readonly property int fontSize: 14
  readonly property int iconSpacing: 12

  readonly property color bg: "#222436"
  readonly property color fg: "#c8d3f5"
  readonly property color dim: "#636da6"
  readonly property color border: "#3b4261"
  readonly property color blue: "#82aaff"
  readonly property color green: "#c3e88d"
  readonly property color yellow: "#ffc777"
  readonly property color red: "#ff757f"

  function signalIcon(strength) {
    return ["󰤟", "󰤢", "󰤥", "󰤨"][Math.min(3, Math.floor(strength * 4))]
  }
}
