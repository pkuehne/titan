pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string fallback: Quickshell.shellDir + "/wallpaper.jpg"
  readonly property string folder: Quickshell.env("HOME") + "/Pictures/Wallpapers"
  readonly property string link: Quickshell.env("HOME") + "/.local/state/titan/wallpaper"
  property string current: ""

  function choose(path) {
    current = path
    Quickshell.execDetached(["sh", "-c", 'mkdir -p "$(dirname "$1")" && ln -sfn "$2" "$1"', "sh", link, path])
  }

  Process {
    running: true
    command: ["sh", "-c", '[ -e "$1" ] && readlink "$1"', "sh", root.link]
    stdout: StdioCollector {
      onStreamFinished: {
        const target = text.trim()
        if (target) root.current = target
        else root.choose(root.fallback)
      }
    }
  }
}
