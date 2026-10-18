import QtQuick
import qs

Row {
  id: root
  property alias icon: glyph.text
  property alias label: label.text
  property color tint: Theme.fg
  spacing: 10

  Text {
    id: glyph
    width: 16
    color: root.tint
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
