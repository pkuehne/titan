import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs

PanelWindow {
  id: root

  readonly property int timeoutMs: 5000
  readonly property int cardWidth: 360

  NotificationServer {
    id: server
    onNotification: notification => notification.tracked = true
  }

  visible: server.trackedNotifications.values.length > 0
  anchors {
    top: true
    right: true
  }
  margins {
    top: 8
    right: 8
  }
  implicitWidth: cardWidth
  implicitHeight: cards.implicitHeight
  color: "transparent"

  Column {
    id: cards
    spacing: 8

    Repeater {
      model: server.trackedNotifications

      Rectangle {
        id: card
        required property var modelData

        width: root.cardWidth
        height: content.implicitHeight + 24
        radius: 8
        color: Theme.bg
        border.color: Theme.border

        Timer {
          running: true
          interval: root.timeoutMs
          onTriggered: card.modelData.expire()
        }

        MouseArea {
          anchors.fill: parent
          onClicked: card.modelData.dismiss()
        }

        Column {
          id: content
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 16
          }
          spacing: 4

          Text {
            width: parent.width
            text: card.modelData.summary
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            elide: Text.ElideRight
          }
          Text {
            width: parent.width
            visible: text !== ""
            text: card.modelData.body
            color: Theme.dim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
