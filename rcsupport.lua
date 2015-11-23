local naughty = require("naughty")
local awful = require("awful")
local wibox = require("wibox")
local notify = require("notify")

local rcsupport = {} 
local debug = false

function rcsupport.is_touchpad_enabled()
    status = awful.util.pread(
        "synclient -l | grep -c 'TouchpadOff.*=.*0'")

    -- Status has a linebreak at the end.
    if status == "1\n" then
        return true
    else
        return false
    end
end

function rcsupport.enable_touchpad()
    awful.util.spawn("synclient TouchpadOff=0", false)
end

function rcsupport.disable_touchpad()
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

-- Sets the X11 keyboard layout to US International. 
function rcsupport.us_intl_kbd_layout()
    cmd = "setxkbmap -rules evdev -model evdev -layout us -variant intl" 
    awful.util.spawn(cmd, false)
end

-- Disable capslock in X11
function rcsupport.disable_capslock()
    cmd = "setxkbmap -option caps:none"   
    awful.util.spawn(cmd, false)
end

function rcsupport.globalkeys(s)

    local prev_tag = function(screen)
        awful.tag.viewprev(screen)
    end

    local next_tag = function(screen)
        awful.tag.viewnext(screen)
    end

    local last_tag = function(screen)
        awful.tag.history.restore(screen)
    end

    local next_client = function ()
        awful.client.focus.byidx( 1)
        if client.focus then 
            client.focus:raise() 
        end
    end
    
    local prev_client = function ()
        awful.client.focus.byidx(-1)
        if client.focus then 
            client.focus:raise() 
        end
    end

    local edit_rclua = function()
        -- TODO: Do this by navigating to the dir using 
        -- awesome.conffile
        cmd = "cd ~/repos/awesome-config && " .. s.editorcmd .. " rc.lua" 
        awful.util.spawn_with_shell(cmd)
    end

    local layout_next = function()
        awful.client.swap.byidx(1)
    end

    local layout_prev = function()
        awful.client.swap.byidx(-1)
    end

    local focus_next = function()
        awful.screen.focus_relative(1)
    end

    local focus_prev = function()
        awful.screen.focus_relative(1)
    end

    local jump_to_urgent = function(client)
        awful.client.urgent.jumpto(client, false)
    end

    local focus_last = function(client)
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end

    local new_terminal = function()
        awful.util.spawn(s.terminal)
    end
    
    local incmwfact = function () 
        awful.tag.incmwfact( 0.05)
    end

    local decmwfact = function () 
        awful.tag.incmwfact(-0.05)    
    end

    local incnmaster = function()
        awful.tag.incnmaster(1)
    end

    local decnmaster = function()
        awful.tag.incnmaster(-1)
    end

    local inc_n_columns = function()
        awful.tag.incncol(1)
    end

    local dec_n_columns = function()
        awful.tag.incncol(-1)
    end
    
    local next_layout = function () 
        awful.layout.inc(s.layouts, 1) 
    end

    local prev_layout = function () 
        awful.layout.inc(s.layouts, -1) 
    end
    
    local run_prompt = function () 
        widgets.promptbox[mouse.screen]:run() 
    end
    
    local show_menu = function() 
        s.menubar.show() 
    end
   
    local toggle_touchpad = function()
        enabled = rcsupport.is_touchpad_enabled()
        if enabled then
            rcsupport.disable_touchpad()
            notify.info("Touchpad disabled!")
        else
            rcsupport.enable_touchpad()
            notify.info("Touchpad enabled!")
        end
    end

    local set_laptop_display = function()
        notify.info("Changed to laptop output!")
        awful.util.spawn("xrandr-laptop.sh", false)
    end

    local set_dual_display = function()
        notify.info("Changed to dual output!")
        awful.util.spawn("xrandr-dual.sh", false)
    end

    local go_to_tag = function()
        notify.dbg(idx) 
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
           awful.tag.viewonly(tag)
        end
    end

    local get_conky = function()
        local clients = client.get()
        local conky = nil
        local i = 1
        while clients[i]
        do
            if clients[i].class == "Conky" 
            then
                conky = clients[i]
            end
            i = i + 1
        end
        return conky
    end

    local raise_conky = function()
        local conky = get_conky()
        if conky
        then
            conky.ontop = true
        end
    end

    local lower_conky = function()
        local conky = get_conky()
        if conky
        then
            conky.ontop = false
        end
    end

    local toggle_conky = function()
        local conky = get_conky()
        if conky
        then
            if conky.ontop
            then
                conky.ontop = false
            else
                conky.ontop = true
            end
        end
    end
   
    local print_selected_tag = function()
        notify.info("inside print_selected_tag")
        tag = awful.tag.selected(1)
    end

    local globalkeys = awful.util.table.join(
        awful.key({ s.modkey,           }, "Left",  prev_tag),
        awful.key({ s.modkey,           }, "Right",  next_tag),
        awful.key({ s.modkey,           }, "Escape", last_tag),
        awful.key({ s.modkey,           }, "j", next_client),
        awful.key({ s.modkey,           }, "k", prev_client),
        awful.key({ s.modkey,           }, "w", show_menu),
        awful.key({ s.modkey,           }, "e", edit_rclua),
        awful.key({ s.modkey,           }, "d", print_selected_tag),

        -- Layout manipulation
        awful.key({ s.modkey, "Shift"   }, "j", layout_next),
        awful.key({ s.modkey, "Shift"   }, "k", layout_prev),
        awful.key({ s.modkey, "Control" }, "j", focus_next),
        awful.key({ s.modkey, "Control" }, "k", focus_prev),
        awful.key({ s.modkey,           }, "Tab", focus_last),
        awful.key({ s.modkey,           }, "u", jump_to_urgent),

        -- Standard program
        awful.key({ s.modkey,           }, "Return", new_terminal),
        awful.key({ s.modkey, "Control" }, "r", awesome.restart),
        awful.key({ s.modkey, "Shift"   }, "q", awesome.quit),

        awful.key({ s.modkey,           }, "l", incmwfact),
        awful.key({ s.modkey,           }, "h", decmwfact),
        awful.key({ s.modkey, "Shift"   }, "h", incnmaster),
        awful.key({ s.modkey, "Shift"   }, "l", decnmaster),
        awful.key({ s.modkey, "Control" }, "h", inc_n_columns),
        awful.key({ s.modkey, "Control" }, "l", dec_n_columns),

        awful.key({ s.modkey,           }, "space", next_layout),
        awful.key({ s.modkey, "Shift"   }, "space", prev_layout),

        awful.key({ s.modkey, "Control" }, "n", awful.client.restore),

        awful.key({ s.modkey,           }, "F1", set_laptop_display),
        awful.key({ s.modkey,           }, "F2", set_dual_display),

        awful.key({ s.modkey,           }, "c", 
            function ()
                local conky_matcher = function (c)
                    return awful.rules.match(c, { class = 'Conky' })
                end
                awful.client.run_or_raise("conky", conky_matcher)
            end),

        -- Prompt
        awful.key({ s.modkey }, "r", run_prompt),

        -- Menubar
        awful.key({ s.modkey }, "p", show_menu),

        -- Toggle touchpad on laptop
        awful.key({ s.modkey }, "/", toggle_touchpad)
    )

    -- Not capable of refactoring this at the moment
    for i = 1, 9 do
        globalkeys = awful.util.table.join(globalkeys,
            awful.key({ s.modkey }, "#" .. i + 9,
                function()
                    local screen = mouse.screen
                    local tag = awful.tag.gettags(mouse.screen)[i]
                    if tag then
                       awful.tag.viewonly(tag)
                    end
                end),
            awful.key({ s.modkey, "Control" }, "#" .. i + 9,
                function(idx)
                    local screen = mouse.screen
                    local tag = awful.tag.gettags(mouse.screen)[i]
                    if tag then
                       awful.tag.viewtoggle(tag)
                    end
                end),
            awful.key({ s.modkey, "Shift" }, "#" .. i + 9,
                function ()
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if client.focus and tag then
                        awful.client.movetotag(tag)
                    end
                end),
            awful.key({ s.modkey, "Control", "Shift" }, "#" .. i + 9,
                function ()
                   local tag = awful.tag.gettags(client.focus.screen)[i]
                   if client.focus and tag then
                       awful.client.toggletag(tag)
                   end
                end))
    end

    return globalkeys
end

function rcsupport.globalbuttons(s)
    
    -- Not used at the moment
    -- local awesomemenu = {
    --    { "manual", s.terminal .. " -e man awesome" },
    --    { "edit config", s.editorcmd .. " " .. awesome.conffile },
    --    { "restart", awesome.restart },
    --    { "quit", awesome.quit }
    -- }

    -- local mainmenu = awful.menu({ 
    --     items = { 
    --         { "awesome", awesomemenu, s.beautiful.awesome_icon },
    --         { "open terminal", terminal }
    --     }
    -- })

    globalbuttons = awful.util.table.join(
        -- awful.button({ }, 3, function () s.mainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev))

    return globalbuttons 
end

function rcsupport.clientbuttons(s)
    clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ s.modkey }, 1, awful.mouse.client.move),
        awful.button({ s.modkey }, 3, awful.mouse.client.resize))

    return clientbuttons
end

function rcsupport.clientkeys(s)
    
    -- Function definitions to avoid clutter
    -- the client keys structure
    local toggle_fullscreen = function (client)
       client.fullscreen = not client.fullscreen 
    end

    local kill_client = function(client)
       client:kill()
    end

    local get_master = function (client) 
        client:swap(awful.client.getmaster()) 
    end

    local move_to_next_screen = function(client)
        awful.client.movetoscreen(client)       
    end

    local toggle_on_top = function(client) 
        client.ontop = not client.ontop
    end

    local minimize = function(client)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        client.minimized = true
    end

    local maximize = function(client)
        client.maximized_horizontal = not client.maximized_horizontal
        client.maximized_vertical   = not client.maximized_vertical
    end

    local clientkeys = awful.util.table.join(
        awful.key({ s.modkey,           }, "f", toggle_fullscreen),
        awful.key({ s.modkey, "Shift"   }, "c", kill_client),
        awful.key({ s.modkey, "Control" }, "Return", get_master),
        awful.key({ s.modkey,           }, "o", move_to_next_screen),
        awful.key({ s.modkey,           }, "t", toggle_on_top),
        awful.key({ s.modkey,           }, "n", minimize),
        awful.key({ s.modkey,           }, "m", maximize)
    )

    return clientkeys
end

function rcsupport.createrules(s, tags)
    rules = {
        -- All clients will match this rule.
        { rule = { },
          properties = { 
              border_width = s.beautiful.border_width,
              border_color = s.beautiful.border_normal,
              focus = awful.client.focus.filter,
              size_hints_honor = false,
              keys = s.clientkeys,
              buttons = s.clientbuttons } },
        { rule = { class = "Conky" },
          properties = { 
              type = desktop, 
              floting = true,
              sticky = true,
              opacity = 0.9,
              focusable = false,
              screen = 1,
              ontop = false } },
    }

    return rules
end

function rcsupport.set_wallpaper(s)
    if s.beautiful.wallpaper then
        for scrn = 1, screen.count() do
            local gears = require("gears")
            gears.wallpaper.maximized(s.beautiful.wallpaper, scrn, true)
        end
    end
end

function rcsupport.create_widgets(s)

    -- Main widget structure
    local widgets = {}
    
    -- Widgets
    widgets.promptbox = {}
    widgets.layoutbox = {}
    widgets.taglist = {}
    widgets.tasklist = {}
    
    -- "Top right corner" widgets
    widgets.clock = awful.widget.textclock()
    widgets.spacing = wibox.widget.textbox()
    widgets.spacing:set_text("  ")
    widgets.separator = wibox.widget.textbox()
    widgets.separator:set_text(" - ")
    widgets.volumewidget = wibox.widget.textbox()
    widgets.batterywidget = wibox.widget.textbox()

    -- Create a promptbox for each screen
    for i = 1,screen.count() do
        widgets.promptbox[i] = awful.widget.prompt()

        -- One layoutbox per screen
        -- Buttons:
        -- 1: Left mouse press
        -- 2: Middle press (?)
        -- 3: Right mouse press
        -- 4: Scroll up
        -- 5: Scroll down 
        widgets.layoutbox[i] = awful.widget.layoutbox(i)
        widgets.layoutbox[i]:buttons(
            awful.util.table.join(
               awful.button({ }, 1, 
                   function() awful.layout.inc(s.layouts, 1) end),
               awful.button({ }, 3, 
                   function() awful.layout.inc(s.layouts, -1) end)
            )
        )

        -- One taglist per screen
        widgets.taglist[i] = awful.widget.taglist(
            i,    
            awful.widget.taglist.filter.all,
            awful.util.table.join(
                awful.button({ }, 1, awful.tag.viewonly),
                awful.button({ s.modkey }, 1, awful.client.movetotag),
                awful.button({ }, 3, awful.tag.viewtoggle),
                awful.button({ s.modkey }, 3, awful.client.toggletag)
            )
        )

        -- Create tasklist
        widgets.tasklist[i] = awful.widget.tasklist(
            i, 
            awful.widget.tasklist.filter.currenttags, 
            awful.util.table.join(
                awful.button({ }, 1, 
                    function (c)
                        if c == client.focus then
                          c.minimized = true
                        else
                          -- Without this, the following
                          -- :isvisible() makes no sense
                          c.minimized = false
                        if not c:isvisible() then
                              awful.tag.viewonly(c:tags()[i])
                        end
                          -- This will also un-minimize
                          -- the client, if needed
                          client.focus = c
                          c:raise()
                        end
                    end
                )
            )
        )
    end

    --Finally, register vicious-dependant widgets
    local vicious = require("vicious")
    vicious.register(
        widgets.volumewidget, 
        vicious.widgets.volume, 
        "♫: $1%", 2, "Master"
    )

    vicious.register(
        widgets.batterywidget, 
        vicious.widgets.bat, 
        "B: $2%", 61, "BAT0"
    )

    return widgets
end

function rcsupport.create_wibox_layouts(widgets)
    
    local layouts = {}
    layouts.wiboxtop = {}
    layouts.wiboxbottom = {}

    for i = 1, screen.count() do
        local topleft = wibox.layout.fixed.horizontal()
        local topmiddle = wibox.layout.fixed.horizontal()
        local topright = wibox.layout.fixed.horizontal()

        topleft:add(widgets.taglist[i])

        topmiddle:fill_space(true)
        topmiddle:add(widgets.promptbox[i])

        topright:add(widgets.spacing)
        topright:add(widgets.batterywidget)
        topright:add(widgets.separator)
        topright:add(widgets.volumewidget)
        topright:add(widgets.separator)
        topright:add(widgets.clock)
        topright:add(widgets.spacing)
        topright:add(widgets.layoutbox[i])

        -- Now bring it all together
        layouts.wiboxtop[i] = wibox.layout.align.horizontal()
        layouts.wiboxtop[i]:set_left(topleft)
        layouts.wiboxtop[i]:set_middle(topmiddle)
        layouts.wiboxtop[i]:set_right(topright)

        layouts.wiboxbottom[i] = wibox.layout.align.horizontal()
        layouts.wiboxbottom[i]:set_middle(widgets.tasklist[i])
    end

    return layouts
end

function rcsupport.create_wiboxes(layouts)
    local wiboxes = {}
    wiboxes.wiboxtop = {}
    wiboxes.wiboxbottom = {}
    
    for i = 1, screen.count() do
        -- Create the wiboxes, this will make them visible
        wiboxes.wiboxtop[i] = awful.wibox(
            { position = "top", screen = i})

        wiboxes.wiboxbottom[i] = awful.wibox(
            { position = "bottom", screen = i})

        -- Add the widget to the wiboxes, 
        -- this will make the layouts visible
        wiboxes.wiboxtop[i]:set_widget(layouts.wiboxtop[i])
        wiboxes.wiboxbottom[i]:set_widget(layouts.wiboxbottom[i]) 
    end

    return wiboxes
end

function rcsupport.create_tags(tagnames)
    local tags = {}
    for i = 1,screen.count() do
        tags[i] = awful.tag(tagnames[i], i, awful.layout.suit.tile)
    end
    return tags
end

return rcsupport
