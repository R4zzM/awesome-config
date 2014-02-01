local naughty = require("naughty")
local awful = require("awful")

local rcsupport = {}

local debug = false

-- Control printouts from dbg function
function rcsupport.enable_dbg()
  debug = true
end

-- Control printouts from dbg function
function rcsupport.disable_dbg()
  debug = false
end

-- Convenience function when debugging
-- Depends on the debug variable
function rcsupport.dbg(msg)
  if debug then
    naughty.notify({ preset = naughty.config.presets.easy,
                     title = "Debug",
                     text = msg })
  end
end

-- Returns hostname as given by the posix `hostname` command
function rcsupport.get_hostname()
  handle = io.popen("hostname")
  hostname = io.input(handle):read()
  return hostname
end

function rcsupport.is_elx()
  hostname = rcsupport.get_hostname()
  start = hostname.sub(hostname, 1, 3)
  if start == "elx" then
    return true
  else
    return false
  end
end

-- Used to autostart applications and is insensitive to awesome restarts
-- Got it from the Awesome wiki.
function rcsupport.run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

return rcsupport
