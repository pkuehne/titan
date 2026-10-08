import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Networking
import qs

PopupWindow {
  id: panel
  required property var device
  required property var network
  property var selected: null
  property string password: ""
  property bool unlocked: false
  readonly property var nearby: device?.networks.values
    .filter(n => n.name && !n.connected)
    .sort((a, b) => b.signalStrength - a.signalStrength) ?? []
  readonly property real strength: network?.signalStrength ?? 0
  readonly property var internet: ({
    [NetworkConnectivity.Full]: ["Online", Theme.green],
    [NetworkConnectivity.Portal]: ["Login required", Theme.yellow],
    [NetworkConnectivity.Limited]: ["No internet", Theme.red],
    [NetworkConnectivity.None]: ["Offline", Theme.red]
  })[Networking.connectivity] ?? ["Unknown", Theme.dim]

  onVisibleChanged: {
    if (visible) Networking.checkConnectivity()
    if (device) device.scannerEnabled = visible
    selected = null
  }

  onSelectedChanged: {
    password = ""
    unlocked = false
  }

  function join(network) {
    if (password) network.connectWithPsk(password)
    else network.connect()
    selected = null
  }

  function disconnect(network) {
    network.disconnect()
    selected = null
  }

  function forget(network) {
    network.forget()
    selected = null
  }

  grabFocus: true

  implicitWidth: details.implicitWidth + 32
  implicitHeight: details.implicitHeight + 24
  color: "transparent"

  // Reusable component row
  component Detail: Row {
    property alias icon: glyph.text
    property alias label: label.text
    property color tint: Theme.fg
    spacing: 10

    Text {
      id: glyph
      width: 16
      color: parent.tint
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
    Text {
      id: label
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: Theme.bg
    border.color: Theme.border

    Column {
      id: details
      anchors.centerIn: parent
      spacing: 6

      Item {
        implicitWidth: current.implicitWidth + toggle.implicitWidth + 16
        implicitHeight: current.implicitHeight
        width: Math.max(implicitWidth, parent.width)

        Detail {
          // Network connectivity status
          id: current
          icon: panel.network ? "󰖩" : "󰖪"
          label: panel.network?.name ?? (Networking.wifiEnabled ? "Disconnected" : "Wifi off")
          tint: panel.network ? Theme.blue : Theme.dim

          TapHandler {
            enabled: !!panel.network
            onTapped: panel.selected = panel.selected === panel.network ? null : panel.network
          }
          HoverHandler {
            enabled: !!panel.network
            cursorShape: Qt.PointingHandCursor
          }
        }

        WifiJoin.Glyph {
          id: toggle
          anchors.right: parent.right
          text: Networking.wifiEnabled ? "󰔡" : "󰨙"
          color: Networking.wifiEnabled ? Theme.green : Theme.dim
          active: Networking.wifiHardwareEnabled
          onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
        }
      }
      WifiJoin {
        visible: !!panel.network && panel.selected === panel.network
        leftPadding: 26
        network: panel.network
        onDisconnected: panel.disconnect(panel.network)
        onForgot: panel.forget(panel.network)
      }
      Detail {
        // Internet access status
        visible: !!panel.network
        icon: "󰖟"
        label: panel.internet[0]
        tint: panel.internet[1]
      }
      Detail {
        // Connection strength
        visible: !!panel.network
        icon: "󰒢"
        label: `${Math.round(panel.strength * 100)}%`
        tint: panel.strength >= 0.6 ? Theme.green : panel.strength >= 0.3 ? Theme.yellow : Theme.red
      }
      Detail {
        // Network security
        visible: !!panel.network
        icon: panel.network?.security === WifiSecurityType.Open ? "󰌿" : "󰌾"
        label: WifiSecurityType.toString(panel.network?.security ?? WifiSecurityType.Unknown)
        tint: Theme.dim
      }

      Rectangle {
        // Divider
        visible: panel.nearby.length > 0
        width: parent.width
        height: 1
        color: Theme.border
      }

      Flickable {
        // Scrollable list of nearby networks
        width: list.implicitWidth + 12
        height: Math.min(list.implicitHeight, (metrics.height + list.spacing) * 10 - list.spacing)
        contentHeight: list.implicitHeight
        clip: true
        ScrollIndicator.vertical: ScrollIndicator {
          visible: size < 1
          contentItem: Rectangle {
            implicitWidth: 2
            radius: 1
            color: Theme.border
          }
        }

        FontMetrics {
          id: metrics
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }

        Column {
          id: list
          spacing: details.spacing

          Repeater {
            model: panel.nearby

            Column {
              id: entry
              required property var modelData
              spacing: list.spacing

              Detail {
                icon: Theme.signalIcon(modelData.signalStrength)
                label: modelData.name + (modelData.security === WifiSecurityType.Open ? "" : "  󰌾")
                tint: modelData.stateChanging ? Theme.yellow : modelData.known ? Theme.blue : Theme.dim

                TapHandler {
                  onTapped: panel.selected = panel.selected === modelData ? null : modelData
                }
                HoverHandler {
                  cursorShape: Qt.PointingHandCursor
                }
              }

              WifiJoin {
                visible: panel.selected === entry.modelData
                leftPadding: 26
                network: entry.modelData
                password: panel.password
                unlocked: panel.unlocked
                onPasswordEdited: text => panel.password = text
                onUnlockRequested: panel.unlocked = true
                onJoined: panel.join(entry.modelData)
                onForgot: panel.forget(entry.modelData)
              }
            }
          }
        }
      }
    }
  }
}
