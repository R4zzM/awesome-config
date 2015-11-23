local naughty = require("naughty")
local notify = {}

-- Set to true to enable debugging
notify.debug = false

-- Convenience function when debugging
-- Depends on the debug variable
function notify.dbg(msg)
    if notify.debug then
        naughty.notify({ 
            preset = naughty.config.presets.easy,
            title = "Debug",
            text = msg 
        })
    end
end

-- Show informational messages
function notify.info(msg)
    naughty.notify({ 
        preset = naughty.config.presets.easy,
        title = "Info",
        text = msg 
    })
end

-- Show an error message
function notify.err(msg)
    naughty.notify({ 
        preset = naughty.config.presets.critical,
        title = "Error!",
        text = msg 
    })
end

return notify
