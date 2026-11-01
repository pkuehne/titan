// Pure helpers for the fan widget. Everything that turns sysfs vocabulary into
// something a human reads lives here, so Panel.qml stays declarative and this
// mapping can be exercised on its own.

var FAN_GLYPH = "󰈐"
var TEMP_GLYPH = "󰔏"

// Ordered coolest → hottest. The ramp is the point: the icon alone should say
// where on the thermal scale a profile sits, without reading the label.
var PROFILE_ICONS = {
  "cool": "󰜗",                  // snowflake
  "quiet": "󰌪",                 // leaf
  "low-power": "󰌪",
  "power-saver": "󰌪",
  "balanced": "󰊚",              // gauge
  "balanced-performance": "󰾅",  // speedometer, needle halfway
  "performance": "󰓅",           // speedometer, needle high
  "custom": "󰒓"                 // cog
}

// Long enough to be unambiguous, short enough for a three-column grid.
var PROFILE_LABELS = {
  "balanced-performance": "Balanced+",
  "low-power": "Low power",
  "power-saver": "Power saver"
}

function profileIcon(name) {
  return PROFILE_ICONS[String(name)] || "󰊚"
}

function profileLabel(name) {
  var key = String(name || "")
  if (PROFILE_LABELS[key]) return PROFILE_LABELS[key]
  if (!key) return ""
  var words = key.replace(/-/g, " ")
  return words.charAt(0).toUpperCase() + words.slice(1)
}

// fanctl emits one `key<TAB>value` pair per line, the same shape the shell's
// other stat readers use.
function parseKeyValue(raw) {
  var out = {}
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length; i++) {
    var idx = lines[i].indexOf("\t")
    if (idx <= 0) continue
    out[lines[i].substring(0, idx)] = lines[i].substring(idx + 1).trim()
  }
  return out
}

function profiles(info) {
  var raw = String((info || {}).choices || "").trim()
  if (!raw) return []
  return raw.split(/\s+/).filter(function (p) { return p.length > 0 })
}

function fans(info) {
  var data = info || {}
  var out = []
  for (var i = 1; i <= 9; i++) {
    var key = "fan" + i
    if (data[key + ".rpm"] === undefined) continue
    var rpm = Number(data[key + ".rpm"]) || 0
    var max = Number(data[key + ".max"]) || 0
    out.push({
      key: key,
      label: data[key + ".label"] || ("Fan " + i),
      rpm: rpm,
      max: max,
      // Falls back to a 6000rpm ceiling so the bar still moves on drivers
      // that never publish fanN_max.
      fraction: Math.max(0, Math.min(1, rpm / (max > 0 ? max : 6000)))
    })
  }
  return out
}

function temps(info) {
  var data = info || {}
  var out = []
  for (var i = 1; i <= 9; i++) {
    var key = "temp" + i
    if (data[key + ".c"] === undefined) continue
    out.push({
      key: key,
      label: data[key + ".label"] || ("Temp " + i),
      celsius: Number(data[key + ".c"]) || 0
    })
  }
  return out
}

function peak(items, field) {
  var best = 0
  for (var i = 0; i < items.length; i++) best = Math.max(best, items[i][field])
  return best
}

// One full turn per interval, faster as the fans climb. Quantised into steps so
// a few rpm of jitter between polls doesn't restart the animation every time.
function spinDuration(rpm, maxRpm) {
  var ceiling = maxRpm > 0 ? maxRpm : 6000
  var ratio = Math.max(0, Math.min(1, rpm / ceiling))
  var step = Math.round(ratio * 8) / 8
  return Math.round(2600 - step * 2300)
}

function clampIndex(index, count) {
  if (count <= 0) return 0
  return Math.max(0, Math.min(count - 1, index))
}

// Horizontal keys walk the list, vertical keys jump a row. Both clamp rather
// than wrap: in a grid this short, wrapping reads as the cursor teleporting.
function moveIndex(index, dx, dy, count, columns) {
  if (count <= 0) return 0
  var cols = Math.max(1, columns)
  var next = index + dx + dy * cols
  if (next < 0 || next >= count) return clampIndex(index, count)
  return next
}

if (typeof module !== "undefined") {
  module.exports = {
    FAN_GLYPH: FAN_GLYPH,
    TEMP_GLYPH: TEMP_GLYPH,
    profileIcon: profileIcon,
    profileLabel: profileLabel,
    parseKeyValue: parseKeyValue,
    profiles: profiles,
    fans: fans,
    temps: temps,
    peak: peak,
    spinDuration: spinDuration,
    clampIndex: clampIndex,
    moveIndex: moveIndex
  }
}
