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

-- Show informational messages
function rcsupport.info(msg)
    naughty.notify({ preset = naughty.config.presets.easy,
                     title = "Info",
                     text = msg })
end

function rcsupport.is_touchpad_enabled()
    status = awful.util.pread("synclient -l | grep -c 'TouchpadOff.*=.*0'")
    -- Finding out that it should be "1\n" took quite some time...
    if status == "1\n" then
        return true
    else
        return false
    end
end

function rcsupport.touchpad_enable()
    awful.util.spawn("synclient TouchpadOff=0", false)
end

function rcsupport.touchpad_disable()
    awful.util.spawn("synclient TouchpadOff=1", false)
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
