import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs

PanelWindow {
  id: root

  readonly property int iconSize: 24
  readonly property var apps: DesktopEntries.applications.values
    .filter(app => !app.noDisplay && matches(app, input.text.toLowerCase()))
    .sort((a, b) => a.name.localeCompare(b.name))

  function matches(app, query) {
    return [app.name, app.genericName, ...app.keywords]
      .some(field => field.toLowerCase().includes(query))
  }

  function launch(app) {
    visible = false
    app.execute()
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
    input.forceActiveFocus()
  }

  IpcHandler {
    target: "launcher"

    function toggle(): void {
      root.visible = !root.visible
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.visible = false
  }

  Rectangle {
    anchors.centerIn: parent
    implicitWidth: 480
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
      onAccepted: if (root.apps.length > 0) root.launch(root.apps[list.currentIndex])
      Keys.onEscapePressed: root.visible = false
      Keys.onUpPressed: list.decrementCurrentIndex()
      Keys.onDownPressed: list.incrementCurrentIndex()

      Text {
        visible: !input.text
        text: "Search applications"
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
      model: root.apps
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
        height: root.iconSize + 12

        Row {
          anchors.verticalCenter: parent.verticalCenter
          x: 8
          spacing: Theme.iconSpacing

          IconImage {
            implicitSize: root.iconSize
            source: Quickshell.iconPath(entry.modelData.icon, "application-x-executable")
          }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: entry.modelData.name
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
          }
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
          onHoveredChanged: if (hovered) list.currentIndex = entry.index
        }
        TapHandler {
          onTapped: root.launch(entry.modelData)
        }
      }
    }
  }
}
