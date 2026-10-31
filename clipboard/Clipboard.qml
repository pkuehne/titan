pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

PanelWindow {
  id: root

  property var entries: []
  readonly property var matches: entries.filter(entry => entry.preview.toLowerCase().includes(input.text.toLowerCase()))

  function copy(entry) {
    visible = false
    Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", entry.id])
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
    input.text = ""
    list.currentIndex = 0
    history.running = true
    input.forceActiveFocus()
  }

  IpcHandler {
    target: "clipboard"

    function toggle(): void {
      root.visible = !root.visible
    }
  }

  Process {
    id: history
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      onStreamFinished: root.entries = text.split("\n").filter(line => line).map(line => {
        const tab = line.indexOf("\t")
        return { id: line.slice(0, tab), preview: line.slice(tab + 1) }
      })
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.visible = false
  }

  Rectangle {
    anchors.centerIn: parent
    implicitWidth: 560
    implicitHeight: 400
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    MouseArea {
      anchors.fill: parent
    }

    TextInput {
      id: input
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 16
      }
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      onTextChanged: list.currentIndex = 0
      onAccepted: if (root.matches.length > 0) root.copy(root.matches[list.currentIndex])
      Keys.onEscapePressed: root.visible = false
      Keys.onUpPressed: list.decrementCurrentIndex()
      Keys.onDownPressed: list.incrementCurrentIndex()

      Text {
        visible: !input.text
        text: "Search clipboard"
        color: Theme.dim
        font: input.font
      }
    }

    ListView {
      id: list
      anchors {
        top: input.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 8
        topMargin: 12
      }
      clip: true
      model: root.matches
      highlightMoveDuration: 0
      highlight: Rectangle {
        radius: 4
        color: Theme.border
      }

      delegate: Item {
        id: entry
        required property var modelData
        required property int index
        width: ListView.view.width
        height: Theme.fontSize + 16

        Text {
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: 8
            rightMargin: 8
          }
          text: entry.modelData.preview
          textFormat: Text.PlainText
          elide: Text.ElideRight
          maximumLineCount: 1
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
          onHoveredChanged: if (hovered) list.currentIndex = entry.index
        }
        TapHandler {
          onTapped: root.copy(entry.modelData)
        }
      }
    }
  }
}
