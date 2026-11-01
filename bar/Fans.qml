import QtQuick
import Quickshell
import Quickshell.Io
import qs
import "FanModel.js" as Model

Text {
  id: root
  readonly property string fanctl: Quickshell.shellDir + "/bar/fanctl"
  readonly property int idleInterval: 10000
  readonly property int openInterval: 2000
  property var info: ({})
  property bool loaded: false
  property string lastError: ""
  readonly property var fans: Model.fans(info)
  readonly property int peakRpm: Model.peak(fans, "rpm")
  readonly property int peakMax: Model.peak(fans, "max")
  readonly property bool supported: !loaded || !!info.profile

  function refresh() {
    if (!sensors.running) sensors.running = true
  }

  function setProfile(name) {
    if (setter.running || info.writable !== "1") return
    lastError = ""
    setter.command = [fanctl, "set", name]
    setter.running = true
  }

  visible: supported
  width: supported ? implicitWidth : 0
  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  text: Model.FAN_GLYPH

  property bool open: false

  NumberAnimation on rotation {
    from: 0
    to: 360
    duration: Model.spinDuration(root.peakRpm, root.peakMax)
    loops: Animation.Infinite
    running: root.peakRpm > 0
    onRunningChanged: if (!running) root.rotation = 0
  }

  Process {
    id: sensors
    command: [root.fanctl, "sensors"]
    stdout: StdioCollector {
      onStreamFinished: {
        const next = Model.parseKeyValue(text)
        if (Object.keys(next).length === 0 && root.loaded) return
        root.info = next
        root.loaded = true
      }
    }
  }

  Process {
    id: setter
    stderr: StdioCollector {
      onStreamFinished: root.lastError = text.trim()
    }
    onExited: root.refresh()
  }

  Timer {
    interval: root.open ? root.openInterval : root.idleInterval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.open = !root.open
  }

  FansPanel {
    visible: root.open
    fans: root.fans
    temps: Model.temps(root.info)
    profile: root.info.profile ?? ""
    choices: Model.profiles(root.info)
    writable: root.info.writable === "1"
    error: root.lastError
    onProfileChosen: name => root.setProfile(name)
    onVisibleChanged: root.open = visible
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
  }
}
