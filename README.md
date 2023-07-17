# iterm.nvim

Set various iTerm2 properties using proprietary escape sequences.

## Install

Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug "izeau/iterm.nvim"
```

Using [Packer](https://github.com/wbthomason/packer.nvim):

```lua
use { "izeau/iterm.nvim" }
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- plugins/iterm.lua
return {
  { "izeau/iterm.nvim", version = false },
}
```

## Options

Defaults values:

```lua
{
  -- properties set when setup() is called, use false to disable
  profile = "Neovim",
  tab_color = false,
  badge = false,
  background_image = false,

  -- properties set when exiting nvim, if auto_reset is true
  auto_reset = true,
  reset_profile = "",
  reset_tab_color = false,
  reset_badge = false,
  reset_background_image = false,
}
```

## API

### Set profile

```lua
require("iterm").set_profile("Neovim")            -- named profile
require("iterm").set_profile("")                  -- default profile
```

### Set badge

```lua
require("iterm").set_badge("nvim@\\(hostname)")   -- interpolated
require("iterm").set_badge("")                    -- clear the badge
```

### Set tab color

```lua
require("iterm").set_tab_color({ 52, 152, 219 })  -- RGB tuple
require("iterm").set_tab_color("#3498db")         -- hex string
require("iterm").set_tab_color(nil)               -- reset the tab color
```

### Set background image

Make sure your theme does not set a background color. Path is normalized, and
relative paths are resolved using the current working directory.

```lua
require("iterm").set_background_image("~/bg.png") -- path is expanded
require("iterm").set_background_image("")         -- remove background
```

### Request attention

#### Flash the current pane

```lua
require("iterm").flash()
```

#### Bounce the dock icon

Only works when iTerm is not focused.

```lua
require("iterm").bounce_once()                    -- bounce once
require("iterm").bounce_start()                   -- start bouncing
require("iterm").bounce_stop()                    -- stop bouncing
```

#### :fireworks:

```lua
require("iterm").fireworks()
```

## Why would you use this?

I personally use it to automatically switch to a different profile when using
Neovim, because iTerm’s built-in automatic profile switching was randomly
failing. My _Neovim_ profile defines a few shortcuts using the _Command_ key,
such as `⌘s` to save no matter the mode you’re currently in. In order to do
this, you have to define a key mapping in your profile (iTerm2 Preferences >
Profiles > Neovim > Keys > Key Mappings) to bind `⌘s` to the _Send Escape
Sequence_ action, and send the `Esc+[25~s` characters to the current session.
`Esc+[25~` is the escape sequence for the `F13` key, which you can then use in
your Neovim config:

```lua
vim.keymap.set({ "n", "i", "v" }, "<f13>s", "<cmd>write<cr>")
```

You can also use it to flash your terminal whenever you enter or exit the insert
mode, if you kind of like that burning sensation on your retina:

```lua
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  callback = function() require("iterm").flash() end,
})
```

You may hook into [nvim-notify](https://github.com/rcarriga/nvim-notify)’s
notification system to bounce the Dock icon whenever you receive a notification
and iTerm is not focused:

```lua
require("nvim-notify").setup({
  on_open = function() require("iterm").bounce_start() end,
})
```

Or perhaps you want to change your terminal tab color when editing a readonly
file?

```lua
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(event)
    if vim.bo[event.buf].readonly then
      require("iterm").set_tab_color("#c0392b")
    end
  end
})

vim.api.nvim_create_autocmd("BufLeave", {
  callback = function() require("iterm").set_tab_color(nil) end
})
```

Finally, if you have a tendency to lose your cursor and the `cursorline` /
`cursorcolumn` options are not enough for you, you can setup a hotkey to setup
an explosion:

```lua
vim.keymap.set("n", "<f1>", function() require("iterm").fireworks() end)
```
