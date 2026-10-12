import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs

PanelWindow {
  id: root

  readonly property int iconSize: 24
  readonly property string installDir: Quickshell.shellDir + "/launcher/install"
  readonly property var known: [
    { id: "firefox", name: "Firefox" },
    { id: "discord", name: "Discord" },
    { id: "com.onepassword.OnePassword", name: "1Password", icon: "1password" },
    { id: "obsidian", name: "Obsidian" },
    { id: "steam", name: "Steam" },
    { id: "syncthing-ui", name: "Syncthing", icon: "syncthing" },
    { id: "localsend", name: "LocalSend" },
    { id: "kitty", name: "Kitty" },
  ]
  readonly property var installed: DesktopEntries.applications.values
  readonly property var missing: known
    .filter(app => !installed.some(entry => entry.id === app.id))
    .map(app => Object.assign({
      icon: app.id,
      genericName: "",
      keywords: [],
      install: `${installDir}/${app.name.toLowerCase()}.sh`,
    }, app))
  readonly property var apps: [...installed, ...missing]
    .filter(app => !app.noDisplay && matches(app, input.text.toLowerCase()))
    .sort((a, b) => rank(a) - rank(b) || a.name.localeCompare(b.name))

  function rank(app) {
    const index = known.findIndex(entry => entry.id === app.id)
    if (index < 0) return 2 * known.length
    return app.install ? known.length + index : index
  }

  function matches(app, query) {
    return [app.name, app.genericName, ...app.keywords]
      .some(field => field.toLowerCase().includes(query))
  }

  function launch(app) {
    visible = false
    if (app.install) Quickshell.execDetached(["kitty", "--hold", app.install])
    else app.execute()
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

        Text {
          visible: !!entry.modelData.install
          anchors.verticalCenter: parent.verticalCenter
          anchors.right: parent.right
          anchors.rightMargin: 8
          text: "install"
          color: Theme.dim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
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
