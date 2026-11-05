pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
  id: root

  readonly property var emojis: [
    { emoji: "😀", name: "grinning face" },
    { emoji: "😃", name: "grinning face with big eyes" },
    { emoji: "😄", name: "grinning face with smiling eyes" },
    { emoji: "😁", name: "beaming face" },
    { emoji: "😆", name: "grinning squinting face" },
    { emoji: "😅", name: "grinning face with sweat" },
    { emoji: "😂", name: "face with tears of joy" },
    { emoji: "🤣", name: "rolling on the floor laughing" },
    { emoji: "🥲", name: "smiling face with tear" },
    { emoji: "😉", name: "winking face" },
    { emoji: "😊", name: "smiling face with smiling eyes" },
    { emoji: "😍", name: "smiling face with heart eyes" },
    { emoji: "🥰", name: "smiling face with hearts" },
    { emoji: "😘", name: "face blowing a kiss" },
    { emoji: "😋", name: "face savoring food" },
    { emoji: "😎", name: "smiling face with sunglasses" },
    { emoji: "🤔", name: "thinking face" },
    { emoji: "🤨", name: "face with raised eyebrow" },
    { emoji: "😐", name: "neutral face" },
    { emoji: "🙄", name: "face with rolling eyes" },
    { emoji: "😴", name: "sleeping face" },
    { emoji: "🥳", name: "partying face" },
    { emoji: "😭", name: "loudly crying face" },
    { emoji: "😡", name: "pouting face" },
    { emoji: "🤯", name: "exploding head" },
    { emoji: "🤗", name: "hugging face" },
    { emoji: "👋", name: "waving hand" },
    { emoji: "👍", name: "thumbs up" },
    { emoji: "👎", name: "thumbs down" },
    { emoji: "👏", name: "clapping hands" },
    { emoji: "🙌", name: "raising hands" },
    { emoji: "🙏", name: "folded hands" },
    { emoji: "💪", name: "flexed biceps" },
    { emoji: "🫶", name: "heart hands" },
    { emoji: "❤️", name: "red heart" },
    { emoji: "🧡", name: "orange heart" },
    { emoji: "💛", name: "yellow heart" },
    { emoji: "💚", name: "green heart" },
    { emoji: "💙", name: "blue heart" },
    { emoji: "💜", name: "purple heart" },
    { emoji: "🖤", name: "black heart" },
    { emoji: "🤍", name: "white heart" },
    { emoji: "💔", name: "broken heart" },
    { emoji: "🔥", name: "fire" },
    { emoji: "✨", name: "sparkles" },
    { emoji: "🎉", name: "party popper" },
    { emoji: "🎂", name: "birthday cake" },
    { emoji: "☕", name: "hot beverage coffee" },
    { emoji: "🍕", name: "pizza" },
    { emoji: "🍺", name: "beer mug" },
    { emoji: "🐱", name: "cat" },
    { emoji: "🐶", name: "dog" },
    { emoji: "🦊", name: "fox" },
    { emoji: "🐼", name: "panda" },
    { emoji: "🦄", name: "unicorn" },
    { emoji: "🌈", name: "rainbow" },
    { emoji: "🌞", name: "sun" },
    { emoji: "🌙", name: "moon" },
    { emoji: "⭐", name: "star" },
    { emoji: "✅", name: "check mark" },
    { emoji: "❌", name: "cross mark" },
    { emoji: "💯", name: "hundred points" },
    { emoji: "🚀", name: "rocket" },
    { emoji: "💻", name: "laptop computer" },
    { emoji: "📱", name: "mobile phone" },
    { emoji: "🎮", name: "video game controller" },
  ]
  readonly property var matches: emojis.filter(entry =>
    entry.name.includes(input.text.toLowerCase()) || entry.emoji.includes(input.text))

  function choose(entry) {
    visible = false
    Quickshell.execDetached(["wl-copy", entry.emoji])
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
    grid.currentIndex = 0
    input.forceActiveFocus()
  }

  IpcHandler {
    target: "emoji"

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
    implicitHeight: 360
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
      onTextChanged: grid.currentIndex = 0
      onAccepted: if (root.matches.length > 0) root.choose(root.matches[grid.currentIndex])
      Keys.onEscapePressed: root.visible = false
      Keys.onUpPressed: grid.moveCurrentIndexUp()
      Keys.onDownPressed: grid.moveCurrentIndexDown()
      Keys.onLeftPressed: grid.moveCurrentIndexLeft()
      Keys.onRightPressed: grid.moveCurrentIndexRight()

      Text {
        visible: !input.text
        text: "Search emoji"
        color: Theme.dim
        font: input.font
      }
    }

    GridView {
      id: grid
      anchors {
        top: input.bottom
        bottom: hint.top
        left: parent.left
        right: parent.right
        margins: 12
        topMargin: 20
      }
      clip: true
      cellWidth: 44
      cellHeight: 44
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
        width: grid.cellWidth
        height: grid.cellHeight

        Text {
          anchors.centerIn: parent
          text: entry.modelData.emoji
          font.pixelSize: 24
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
          onHoveredChanged: if (hovered) grid.currentIndex = entry.index
        }
        TapHandler {
          onTapped: root.choose(entry.modelData)
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
      text: "Select an emoji to copy it"
      color: Theme.dim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }
}
