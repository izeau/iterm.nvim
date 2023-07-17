local aucmd = nil
local config = nil

local default_config = {
  profile = "Neovim",
  tab_color = false,
  badge = false,
  background_image = false,

  auto_reset = true,

  reset_profile = "",
  reset_tab_color = false,
  reset_badge = false,
  reset_background_image = false,
}

local M = {}

M.setup = function(opts)
  config = vim.tbl_extend("force", default_config, opts or {})

  if config.profile ~= false then M.set_profile(config.profile) end
  if config.tab_color ~= false then M.set_tab_color(config.tab_color) end
  if config.badge ~= false then M.set_badge(config.badge) end
  if config.background_image ~= false then M.set_background_image(config.background_image) end

  if config.auto_reset and aucmd == nil then
    aucmd = vim.api.nvim_create_autocmd("VimLeave", {
      callback = function()
        if config.reset_profile ~= false then M.set_profile(config.reset_profile) end
        if config.reset_tab_color then M.set_tab_color(config.reset_tab_color) end
        if config.reset_badge then M.set_badge(config.reset_badge) end
        if config.reset_background_image then M.set_badge(config.reset_background_image) end
      end,
    })
  elseif not config.auto_reset and aucmd ~= nil then
    vim.api.nvim_del_autocmd(aucmd)
    aucmd = nil
  end
end

M.set_profile = function(name)
  io.write("\x1b]1337;SetProfile=" .. name .. "\x07")
end

M.set_badge = function(format)
  io.write("\x1b]1337;SetBadgeFormat=" .. require("iterm.base64").encode(format) .. "\x07")
end

M.set_background_image = function(path)
  io.write("\x1b]1337;SetBackgroundImageFile=" .. require("iterm.base64").encode(path) .. "\x07")
end

M.set_tab_color = function(color)
  if color == nil then
    io.write("\x1b]6;1;bg;*;default\x07")
    return
  end

  if type(color) == "string" then
    if color:sub(1, 1) == "#" then
      color = {
        tonumber(color:sub(2, 3), 16),
        tonumber(color:sub(4, 5), 16),
        tonumber(color:sub(6, 7), 16),
      }
    end
  end

  io.write(table.concat({
    "\x1b]6;1;bg;red;brightness;" .. color[1] .. "\x07",
    "\x1b]6;1;bg;green;brightness;" .. color[2] .. "\x07",
    "\x1b]6;1;bg;blue;brightness;" .. color[3] .. "\x07",
  }, ""))
end

local function request_attention(type)
  return function()
    io.write("\x1b]1337;RequestAttention=" .. type .. "\x07")
  end
end

M.flash = request_attention("flash")
M.bounce_once = request_attention("once")
M.bounce_start = request_attention("yes")
M.bounce_stop = request_attention("no")
M.fireworks = vim.schedule_wrap(request_attention("fireworks"))

return M
