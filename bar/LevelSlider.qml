import QtQuick
import QtQuick.Controls
import qs

Slider {
  id: slider
  property color fill: Theme.blue

  implicitWidth: 160

  background: Rectangle {
    x: slider.leftPadding
    y: slider.topPadding + (slider.availableHeight - height) / 2
    width: slider.availableWidth
    height: 4
    radius: 2
    color: Theme.border

    Rectangle {
      width: slider.visualPosition * parent.width
      height: parent.height
      radius: 2
      color: slider.fill
    }
  }

  handle: Rectangle {
    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
    y: slider.topPadding + (slider.availableHeight - height) / 2
    implicitWidth: 12
    implicitHeight: 12
    radius: 6
    color: Theme.fg
  }
}
