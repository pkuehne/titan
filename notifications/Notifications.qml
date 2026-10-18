pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs

PanelWindow {
  id: root

  readonly property int defaultTimeoutMs: 5000
  readonly property int cardWidth: 360
  readonly property int gap: 8
  readonly property int iconSize: 32

  function icon(notification) {
    if (notification.image) return notification.image
    const name = notification.appIcon
      || DesktopEntries.heuristicLookup(notification.desktopEntry || notification.appName)?.icon
      || ""
    if (name.startsWith("/")) return `file://${name}`
    if (name.includes("://")) return name
    return name ? Quickshell.iconPath(name, true) : ""
  }

  NotificationServer {
    id: server
    actionsSupported: true
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
        readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

        width: root.cardWidth
        height: content.implicitHeight + 24
        radius: 8
        color: Theme.bg
        border.color: critical ? Theme.red : Theme.border

        Rectangle {
          visible: countdown.running
          anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 4
          }
          width: card.width - 8
          height: 2
          radius: 1
          color: Theme.blue

          NumberAnimation on width {
            id: countdown
            to: 0
            duration: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout : root.defaultTimeoutMs
            running: !card.critical && card.modelData.expireTimeout !== 0
            paused: hover.containsMouse
            onFinished: card.modelData.expire()
          }
        }

        MouseArea {
          id: hover
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            const action = card.modelData.actions.find(a => a.identifier === "default")
            if (action) action.invoke()
            else card.modelData.dismiss()
          }
        }

        Row {
          id: content
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 16
          }
          spacing: 12

          IconImage {
            id: appIcon
            visible: source.toString() !== ""
            implicitSize: root.iconSize
            source: root.icon(card.modelData)
          }

          Column {
            width: parent.width - (appIcon.visible ? appIcon.width + parent.spacing : 0)
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
}
