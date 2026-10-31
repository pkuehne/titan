import QtQuick
import Quickshell
import Quickshell.Io
import qs

Text {
  id: root
  readonly property string device: "intel_backlight"
  readonly property real step: 0.1
  readonly property real minimum: 0.01
  property real level: 0
  readonly property string icon: ["󰃞", "󰃟", "󰃠"][Math.min(2, Math.floor(level * 3))]

  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: icon

  property bool open: false
  property bool pinned: false

  onOpenChanged: if (!open) pinned = false

  function set(value) {
    level = Math.max(minimum, Math.min(1, value))
    Quickshell.execDetached(["brightnessctl", "-q", "-d", device, "set", `${Math.round(level * 100)}%`])
    flash()
  }

  function flash() {
    open = true
    hideTimer.restart()
  }

  IpcHandler {
    target: "brightness"

    function up(): void {
      root.set(root.level + root.step)
    }

    function down(): void {
      root.set(root.level - root.step)
    }
  }

  Process {
    id: reader
    running: true
    command: ["brightnessctl", "-m", "-d", root.device, "info"]
    stdout: StdioCollector {
      onStreamFinished: root.level = parseInt(text.split(",")[3]) / 100
    }
  }

  Timer {
    id: hideTimer
    interval: 2000
    onTriggered: {
      if (panel.hovered) restart()
      else if (!root.pinned) root.open = false
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      if (root.pinned) {
        root.open = false
      } else {
        reader.running = true
        root.pinned = true
        root.open = true
      }
    }
  }

  BrightnessPanel {
    id: panel
    visible: root.open
    grabFocus: root.pinned
    icon: root.icon
    level: root.level
    onMoved: value => root.set(value)
    onVisibleChanged: root.open = visible
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
