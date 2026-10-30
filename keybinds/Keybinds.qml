pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

PanelWindow {
  id: root

  readonly property int keyWidth: 360
  readonly property var mods: [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"]]
  readonly property var names: ({
    "mouse:272": "LMB",
    "mouse:273": "RMB",
    "mouse_down": "Scroll ↓",
    "mouse_up": "Scroll ↑",
    "left": "←",
    "right": "→",
    "up": "↑",
    "down": "↓",
    "Page_Down": "PgDn",
    "Page_Up": "PgUp",
    "grave": "`",
    "slash": "/",
    "bracketleft": "[",
    "bracketright": "]",
    "comma": ",",
    "period": ".",
    "minus": "-",
    "equal": "=",
  })
  property var binds: []

  function label(bind) {
    const held = mods.filter(([mask]) => bind.modmask & mask).map(([, name]) => name)
    return [...held, names[bind.key] ?? bind.key].join("+")
  }

  function group(all) {
    const groups = new Map()
    for (const bind of all.filter(b => b.has_description)) {
      if (!groups.has(bind.description)) groups.set(bind.description, [])
      groups.get(bind.description).push(label(bind))
    }
    return [...groups].map(([description, keys]) => ({
      description,
      keys: keys.length > 2 ? `${keys[0]} … ${keys[keys.length - 1]}` : keys.join(" / "),
    }))
  }

  visible: false
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onVisibleChanged: {
    if (!visible) return
    hyprctl.running = true
    list.positionViewAtBeginning()
    list.forceActiveFocus()
  }

  IpcHandler {
    target: "keybinds"

    function toggle(): void {
      root.visible = !root.visible
    }
  }

  Process {
    id: hyprctl
    command: ["hyprctl", "binds", "-j"]
    stdout: StdioCollector {
      onStreamFinished: root.binds = root.group(JSON.parse(text))
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.visible = false
  }

  Rectangle {
    anchors.centerIn: parent
    implicitWidth: root.keyWidth + 360
    implicitHeight: root.height * 0.7
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    MouseArea {
      anchors.fill: parent
    }

    ListView {
      id: list
      anchors.fill: parent
      anchors.margins: 16
      clip: true
      model: root.binds
      Keys.onEscapePressed: root.visible = false
      Keys.onUpPressed: flick(0, 800)
      Keys.onDownPressed: flick(0, -800)

      delegate: Row {
        id: entry
        required property var modelData
        height: Theme.fontSize + 12

        Text {
          width: root.keyWidth
          text: entry.modelData.keys
          color: Theme.blue
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }
        Text {
          text: entry.modelData.description
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }
      }
    }
  }
}
