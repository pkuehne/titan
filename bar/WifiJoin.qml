import QtQuick
import Quickshell.Networking
import qs

Row {
  id: root
  required property var network
  property string password
  property bool unlocked
  readonly property bool needsPassword: !network?.connected && network?.security !== WifiSecurityType.Open
  readonly property bool locked: !!network?.known && !unlocked
  readonly property bool ready: !needsPassword || locked || password.length > 0

  signal passwordEdited(string text)
  signal unlockRequested()
  signal joined()
  signal disconnected()
  signal forgot()

  spacing: 8

  component Glyph: Text {
    id: glyph
    property bool active: true
    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    opacity: active ? 1 : 0.5
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    TapHandler {
      enabled: glyph.active
      onTapped: glyph.clicked()
    }
    HoverHandler {
      enabled: glyph.active
      cursorShape: Qt.PointingHandCursor
    }
  }

  Rectangle {
    implicitWidth: 160
    implicitHeight: input.implicitHeight + 8
    radius: 4
    color: "transparent"
    border.color: root.needsPassword ? Theme.border : "transparent"

    Text {
      visible: !root.needsPassword
      anchors.verticalCenter: parent.verticalCenter
      x: 8
      text: root.network?.connected ? "Connected" : "Open network"
      color: Theme.dim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }

    TextInput {
      id: input
      visible: root.needsPassword
      anchors.fill: parent
      anchors.margins: 4
      anchors.leftMargin: 8
      clip: true
      echoMode: TextInput.Password
      readOnly: root.locked
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      text: root.locked ? "saved-pw" : root.password
      onTextEdited: root.passwordEdited(text)
      onAccepted: if (root.ready) root.joined()
      onVisibleChanged: if (visible && !readOnly) forceActiveFocus()
      onReadOnlyChanged: if (!readOnly) forceActiveFocus()
      Component.onCompleted: if (visible && !readOnly) forceActiveFocus()
    }
  }

  Glyph {
    visible: root.needsPassword && root.locked
    text: "󰑐"
    color: Theme.dim
    onClicked: root.unlockRequested()
  }

  Glyph {
    visible: !root.network?.connected
    text: "󰌘"
    color: Theme.green
    active: root.ready
    onClicked: root.joined()
  }

  Glyph {
    visible: !!root.network?.connected
    text: "󰌸"
    color: Theme.yellow
    onClicked: root.disconnected()
  }

  Glyph {
    visible: !!root.network?.known
    text: "󰆴"
    color: Theme.red
    onClicked: root.forgot()
  }
}
