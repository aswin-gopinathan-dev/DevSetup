local wezterm = require 'wezterm'
local act = wezterm.action

local icons = {
  nvim = "",
  python = "",
  pwsh = "",
  powershell = "",
  cmd = "",
  Git = "",
  bash = "",
  zsh = "",
  SuperFile = "󰉋",
  default = "",
}

local function basename(s)
  return s and s:gsub("^.+[/\\]", ""):gsub("%.exe$", "") or ""
end

local function tab_label(tab)
  -- 1️⃣ Manual rename always wins
  if tab.tab_title and #tab.tab_title > 0 then
  local icon = icons[tab.tab_title] or icons.default
    return icon .. "   " .. tab.tab_title
  end

  -- 2️⃣ Detect foreground process
  local proc = basename(tab.active_pane.foreground_process_name)
  local icon = icons[proc] or icons.default

  return icon .. "    " .. (proc ~= "" and proc or tab.active_pane.title)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local index = tab.tab_index + 1
  local title = tab_label(tab)

  -- optional fixed width
  local width = 40
  if #title > width then
    title = string.format("%d.  ", index) .. title:sub(1, width)
  else
    title = string.format("%d.  ", index) .. title .. string.rep(" ", width - #title)
  end

  return " " .. title .. " "
end)


local config = wezterm.config_builder()
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end

  return " " .. title
end)


return {
	default_prog = { "pwsh.exe", "-NoLogo" },
	keys = {
		{
		  key = "r",
		  mods = "CTRL|SHIFT",
		  action = act.PromptInputLine {
			description = "Rename tab",
			action = wezterm.action_callback(function(window, pane, line)
			  if line then
				window:active_tab():set_title(line)
			  end
			end),
		  },
		},
		
		{
		  key = "c",
		  mods = "CTRL|SHIFT",
		  action = act.CopyTo("Clipboard"),
		},
		
		{
		  key = "v",
		  mods = "CTRL|SHIFT",
		  action = act.PasteFrom("Clipboard"),
		},
		
		-- Ctrl+C must go to the terminal application
		{
		  key = "c",
		  mods = "CTRL",
		  action = act.SendKey { key = "c", mods = "CTRL" },
		},

		-- Ctrl+V must go to the terminal application
		{
		  key = "v",
		  mods = "CTRL",
		  action = act.SendKey { key = "v", mods = "CTRL" },
		},
		
		--[[{
		  key = "c",
		  mods = "CTRL|SHIFT",
		  action = act.SendKey { key = "c", mods = "CTRL" },
		},]]
	},
    window_padding = {
	    left = 0,
	    right = 0,
  	    top = 0,
	    bottom = 0,
	},
	
	foreground_text_hsb = {
	  hue = 1.0,         -- leave hue alone
	  saturation = 1.0, -- +10% saturation
	  brightness = 1.50, -- +20% brightness
	},

    font = wezterm.font("JetBrainsMono Nerd Font", {weight = "Medium"}),
    font_size = 9,
    line_height = 1.2,
	
	enable_scroll_bar = true,
	
	force_reverse_video_cursor = true,
	
	
	freetype_load_flags = "DEFAULT",
	--freetype_render_target = "HorizontalLcd",
	
    color_scheme = "terafox",
}
