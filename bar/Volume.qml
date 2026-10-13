import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

Text {
  id: root
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var audio: sink?.ready ? sink.audio : null
  readonly property bool muted: audio?.muted ?? true
  readonly property string icon: muted ? "󰝟" : ["󰕿", "󰖀", "󰕾"][Math.min(2, Math.floor((audio?.volume ?? 0) * 3))]

  color: muted ? Theme.dim : Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: icon

  property bool open: false
  property bool pinned: false

  onOpenChanged: if (!open) pinned = false

  PwObjectTracker {
    objects: [root.sink]
  }

  Connections {
    target: root.audio

    function onVolumeChanged() {
      root.flash()
    }

    function onMutedChanged() {
      root.flash()
    }
  }

  function flash() {
    open = true
    hideTimer.restart()
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
        root.pinned = true
        root.open = true
      }
    }
  }

  VolumePanel {
    id: panel
    visible: root.open
    grabFocus: root.pinned
    audio: root.audio
    icon: root.icon
    label: root.sink?.description ?? "No output"
    onVisibleChanged: root.open = visible
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
