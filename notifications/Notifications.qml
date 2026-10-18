pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs

PanelWindow {
  id: root

  readonly property int defaultTimeoutMs: 5000
  readonly property int cardWidth: 360
  readonly property int gap: 8

  NotificationServer {
    id: server
    onNotification: notification => notification.tracked = true
  }

  visible: notifications.count > 0
  anchors {
    top: true
    right: true
  }
  implicitWidth: cardWidth + gap
  implicitHeight: cards.implicitHeight + gap
  color: "transparent"

  Column {
    id: cards
    y: root.gap
    spacing: root.gap

    Repeater {
      id: notifications
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
          running: card.modelData.expireTimeout !== 0
          interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout : root.defaultTimeoutMs
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
