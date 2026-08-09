-- Cross-display tiling for macOS, via Hammerspoon.
--
-- The macOS counterpart of the GNOME cross-monitor-tiling extension: a 3x3 grid
-- on the display you are on, or the same position on the next display.
--
--   Y  K  U      top-left      top-half      top-right
--   H  I  L      left-half     fill          right-half
--   B  J  N      bottom-left   bottom-half   bottom-right
--
-- Install: see INSTALL.md in this directory.

-------------------------------------------------------------------------------
-- Configuration
-------------------------------------------------------------------------------

-- Modifier names: Control is "ctrl", Option is "alt", Command is "cmd".
--
-- Control+Option+<letter> is used by almost nothing on macOS, so all 18
-- shortcuts are collision-free. The one exception is VoiceOver, whose "VO"
-- modifier is Control+Option: while VoiceOver is on, these bindings fight it.
local CURRENT_DISPLAY = {"ctrl", "alt"}           -- Control+Option
local OTHER_DISPLAY   = {"ctrl", "alt", "shift"}  -- Control+Option+Shift

-- Position-faithful alternative. On a Mac keyboard Option sits where Super does
-- on a PC keyboard, and Command where Alt does, so this pair is the literal
-- translation of the GNOME Super+Alt / Super+Shift bindings. It costs real
-- shortcuts, though: Hammerspoon's global hotkeys beat application ones, so
-- Cmd+Opt+I / J / U (Web Inspector, JavaScript Console, View Source),
-- Cmd+Opt+H (Hide Others) and Cmd+Opt+B / L / N stop working while it runs.
-- See INSTALL.md for the full list.
--
-- local CURRENT_DISPLAY = {"alt", "cmd"}
-- local OTHER_DISPLAY   = {"alt", "shift"}

-- With only the built-in display connected, should the "other display" keys
-- still tile on the display you are on?
--
-- true  keeps all 18 keys useful on the laptop alone (recommended).
-- false makes them do nothing, which is what the GNOME version does.
local SINGLE_DISPLAY_FALLBACK = true

-------------------------------------------------------------------------------

-- Instant placement, no slide animation, matching the GNOME setup.
hs.window.animationDuration = 0

-- Each cell lists the edges it spans, as indices:
--   x: 1 = left,  2 = middle, 3 = right
--   y: 1 = top,   2 = middle, 3 = bottom
-- Written as {x1, y1, x2, y2}.
local CELLS = {
    y = {1, 1, 2, 2}, k = {1, 1, 3, 2}, u = {2, 1, 3, 2},
    h = {1, 1, 2, 3}, i = {1, 1, 3, 3}, l = {2, 1, 3, 3},
    b = {1, 2, 2, 3}, j = {1, 2, 3, 3}, n = {2, 2, 3, 3},
}

-- Integer edges, shared between neighbours, so halves and quarters tile with
-- neither a seam nor a one-pixel overlap. Same approach as the GNOME version.
local function edgesOf(f)
    local xs = {f.x, f.x + math.floor(f.w / 2 + 0.5), f.x + f.w}
    local ys = {f.y, f.y + math.floor(f.h / 2 + 0.5), f.y + f.h}
    return xs, ys
end

-- Apps are allowed to round or refuse a size, so compare with a small slack
-- rather than exactly.
local function closeEnough(a, b)
    return math.abs(a.x - b.x) <= 2 and math.abs(a.y - b.y) <= 2
       and math.abs(a.w - b.w) <= 2 and math.abs(a.h - b.h) <= 2
end

-- The placement itself. Split out from place() because the fullscreen case has
-- to run it later rather than immediately; see place().
local function apply(win, cell, toOtherDisplay)
    local screen = win:screen()
    if not screen then return end

    if toOtherDisplay then
        -- next() wraps around, so with a single display it returns that same
        -- display rather than nil.
        local other = screen:next()
        if other and other:id() ~= screen:id() then
            screen = other
        elseif not SINGLE_DISPLAY_FALLBACK then
            return
        end
    end

    -- frame() is the usable area: it already excludes the menu bar, the Dock and
    -- the notch. fullFrame() would include them.
    local f = screen:frame()
    local xs, ys = edgesOf(f)
    local x1, y1 = xs[cell[1]], ys[cell[2]]
    local x2, y2 = xs[cell[3]], ys[cell[4]]
    local target = hs.geometry.rect(x1, y1, x2 - x1, y2 - y1)

    win:setFrame(target)

    -- Retry once if it did not land. Cross-display moves and a few stubborn apps
    -- only partly honour the first request; the GNOME version needs the same
    -- second pass. Conditional, so well-behaved apps are not moved twice.
    if not closeEnough(win:frame(), target) then
        win:setFrame(target)
    end
end

local function place(cell, toOtherDisplay)
    local win = hs.window.focusedWindow()
    if not win or not win:isStandard() then return end

    -- A natively fullscreened window ignores setFrame until it leaves
    -- fullscreen. This is the one step that does not port straight across from
    -- GNOME: Mutter's unmake_fullscreen() has taken effect by the time the next
    -- line runs, whereas setFullScreen(false) only *starts* an animated Space
    -- transition and returns immediately. Placing the window now, as the GNOME
    -- order would, silently does nothing - the retry in apply() included, since
    -- that also runs before the transition finishes. So wait it out instead.
    if win:isFullScreen() then
        win:setFullScreen(false)
        hs.timer.waitWhile(
            function() return win:isFullScreen() end,
            -- isFullScreen() flips as soon as the state changes, a little before
            -- the frame settles, so let it finish before measuring anything.
            function()
                hs.timer.doAfter(0.15, function() apply(win, cell, toOtherDisplay) end)
            end,
            0.05)
        return
    end

    apply(win, cell, toOtherDisplay)
end

for key, cell in pairs(CELLS) do
    hs.hotkey.bind(CURRENT_DISPLAY, key, function() place(cell, false) end)
    hs.hotkey.bind(OTHER_DISPLAY,   key, function() place(cell, true) end)
end

hs.alert.show("Tiling loaded: " .. tostring(#hs.screen.allScreens()) .. " display(s)")
