pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

PanelWindow {
  id: root

  readonly property int thumbWidth: 192
  readonly property int thumbHeight: 120
  readonly property int columns: 3
  readonly property int gap: 8
  readonly property var images: {
    const files = []
    for (let i = 0; i < folder.count; i++) files.push(folder.get(i, "filePath"))
    return [WallpaperState.fallback, ...files]
  }

  function choose(path) {
    visible = false
    WallpaperState.choose(path)
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
    grid.currentIndex = Math.max(0, images.indexOf(WallpaperState.current))
    grid.forceActiveFocus()
  }

  IpcHandler {
    target: "wallpaper"

    function toggle(): void {
      root.visible = !root.visible
    }
  }

  FolderListModel {
    id: folder
    folder: "file://" + WallpaperState.folder
    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
    caseSensitive: false
    showDirs: false
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.visible = false
  }

  Rectangle {
    anchors.centerIn: parent
    implicitWidth: root.columns * (root.thumbWidth + root.gap) + 24
    implicitHeight: 3 * (root.thumbHeight + root.gap) + hint.height + 40
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    MouseArea {
      anchors.fill: parent
    }

    GridView {
      id: grid
      anchors {
        top: parent.top
        bottom: hint.top
        left: parent.left
        right: parent.right
        margins: 12
        bottomMargin: 8
      }
      clip: true
      cellWidth: root.thumbWidth + root.gap
      cellHeight: root.thumbHeight + root.gap
      model: root.images
      Keys.onReturnPressed: root.choose(root.images[currentIndex])
      Keys.onEscapePressed: root.visible = false

      delegate: Item {
        id: tile
        required property string modelData
        required property int index
        width: grid.cellWidth
        height: grid.cellHeight

        Rectangle {
          anchors.fill: parent
          anchors.margins: root.gap / 2
          radius: 4
          color: Theme.border
          border.width: 2
          border.color: tile.modelData === WallpaperState.current ? Theme.blue : grid.currentIndex === tile.index ? Theme.fg : "transparent"

          Image {
            anchors.fill: parent
            anchors.margins: 2
            source: "file://" + tile.modelData
            sourceSize.width: root.thumbWidth * 2
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
          }
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
          onHoveredChanged: if (hovered) grid.currentIndex = tile.index
        }
        TapHandler {
          onTapped: root.choose(tile.modelData)
        }
      }
    }

    Text {
      id: hint
      anchors {
        bottom: parent.bottom
        left: parent.left
        margins: 16
      }
      text: `Add images to ${WallpaperState.folder.replace(Quickshell.env("HOME"), "~")}`
      color: Theme.dim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }
}
