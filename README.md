# jjui.nvim

A Neovim plugin to toggle the excellent [jjui](https://github.com/idursun/jjui) TUI in a floating terminal.

This is my first Neovim plugin. I hope you find it useful!

![Showcase](https://raw.githubusercontent.com/ReKylee/jjui.nvim/refs/heads/main/media/example.gif)

## ✨ Features

- Toggle the `jjui` interface in a floating window using `:JJUI`.
- Prompts to initialize a new repository if you're not already in one.
- Optimized for fast startup by launching a clean terminal session.
- Configurable keymaps for easy access.
- Uses [folke/snacks.nvim](https://github.com/folke/snacks.nvim) for UI management.

## ⚡️ Requirements

- Neovim >= 0.8.0
- [Jujutsu](https://github.com/martinvonz/jj)
- [jjui](https://github.com/idursun/jjui)
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim)

## 📦 Installation

Install with your favorite plugin manager.

### lazy.nvim

```lua
-- lua/plugins/jjui.lua
return {
  "your-username/jjui.nvim",
  dependencies = { "folke/snacks.nvim" },
  -- `opts` will be passed to the setup function automatically
  opts = {
    -- your custom options here
  },
}
```

### packer.nvim

```Lua
-- lua/plugins.lua
use({
"your-username/jjui.nvim",
requires = { "folke/snacks.nvim" },
config = function()
require("jjui").setup({
-- your custom options here
})
end,
})
```

## ⚙️ Configuration

You can override the default configuration by passing options to the setup function. The plugin will automatically set up the keymaps defined in your config.

```Lua
-- Default configuration:
require("jjui").setup({
  -- The command to launch jjui. Assumes it's in the system's PATH.
  executable = "jjui",

  -- Launch the terminal with flags to skip loading shell profiles for faster startup.
  fast_shell = true,

  -- The terminal editor to use for interactive commands like `jj describe`.
  editor = "vim",

  -- Keymaps for the plugin. Set to `false` to disable a keymap.
  keymaps = {
    toggle = "<leader>jj",
  },

  -- Options passed directly to snacks.nvim
  terminal_opts = {
    win = {
      title = "Jujutsu UI",
      border = "rounded",
      width = 0.9,
      height = 0.9,
    },
  },
})
```

## Usage

The plugin provides one command, which is primarily intended to be used via its keymap.

- :JJUI - Opens or closes the jjui window.

By default, this is mapped to <leader>jj, but you can change this in the keymaps section of your configuration.

## Credits

- This plugin would not be possible without jjui by idursun.

- UI and terminal management is handled by folke/snacks.nvim.
