-- Support library for printing
local notify = require("notify")

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then 
            return 
        end

        in_error = true
        notify.err(err)
        in_error = false 
    end)
end

-- Standard awesome library
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
require("awful.remote")

-- R4zzMs totally awesome support library
local rcsupport = require("rcsupport")

-- Map with the global config.
-- Add all properties that has no dependancies
local s = {}
s.modkey = "Mod4"
s.terminal = "urxvt"
s.editor = os.getenv("EDITOR") or "vim"
s.editorcmd = s.terminal .. " -e " .. s.editor
s.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}

-- Tagnames, dependant on the number of screens
local tagnames = {}
if screen.count() == 1 then 
    tagnames = { { " Intanetto ", " Code ", " Slask ", " Spottan " } }
elseif screen.count() == 2 then
    tagnames = { 
        { " Intanetto ", " Master ", " Editor ", " Debugger ", " Aux1 ", " Aux2 "},
        { " Slask ", " Log ", " Browser " } 
    }
end

awful.util.spawn_with_shell("xscreensaver -no-splash")

-- Start composite window manager. Needed for transparent windows
awful.util.spawn_with_shell("unagi &")

-- Add and init beautiful, set the wallpaper
s.beautiful = require("beautiful")
s.beautiful.init("/home/rasmus/.config/awesome/themes/current/theme.lua")
rcsupport.set_wallpaper(s)

-- Add the menubar
s.menubar = require("menubar")
s.menubar.utils.terminal = s.terminal

-- Add wiboxes with all widgets on the screens
local tags = rcsupport.create_tags(tagnames)
widgets = rcsupport.create_widgets(s)
layouts = rcsupport.create_wibox_layouts(widgets)
rcsupport.create_wiboxes(layouts)

-- Create and activate global mouse and keybord bindings
local globalbuttons = rcsupport.globalbuttons(s)
local globalkeys = rcsupport.globalkeys(s)
root.buttons(globalbuttons)
root.keys(globalkeys)

-- Create and activate per-client keyboard and mouse bindnings
s.clientkeys = rcsupport.clientkeys(s)
s.clientbuttons = rcsupport.clientbuttons(s)
awful.rules.rules = rcsupport.createrules(s, tags)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
                    -- notify.info(
                    --     "mouse::enter " .. c.name .. 
                    --     ", Minimized = " .. tostring(c.minimized)
                    -- )
                    client.focus = c
            end
    end)
    
    -- Tmp
    -- c:connect_signal("mouse::leave", function(c)
    --     notify.info(
    --         "mouse::leave" ..
    --         ", Name = " .. c.name .. 
    --         ", Minimized = " .. tostring(c.minimized)
    --     )
    -- end)

    -- Conky should always be visible on first screen
    if c.class == "Conky" and c.screen ~= 1 then
        notify.info("Conky screen = " .. c.screen)
        awful.client.movetoscreen(c, 1)
        notify.info("Conky screen = " .. c.screen)
    end

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an 
        -- initial position.
        if not c.size_hints.user_position and not 
            c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- Set border focus when hovering with mouse
client.connect_signal("focus", 
    function(c) 
        c.border_color = s.beautiful.border_focus 
    end)

-- Set border unfoucus when mouse leaves
client.connect_signal("unfocus", 
    function(c) 
        c.border_color = s.beautiful.border_normal 
    end)

