import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Scope {
  id: root

  property MprisPlayer last: null

  function current() {
    const players = Mpris.players.values
    last = players.find(p => p.isPlaying) ?? (players.includes(last) ? last : players[0] ?? null)
    return last
  }

  IpcHandler {
    target: "media"

    function playPause(): void {
      const player = root.current()
      if (player?.canTogglePlaying) player.togglePlaying()
    }

    function stop(): void {
      root.current()?.stop()
    }

    function next(): void {
      const player = root.current()
      if (player?.canGoNext) player.next()
    }

    function previous(): void {
      const player = root.current()
      if (player?.canGoPrevious) player.previous()
    }
  }
}
