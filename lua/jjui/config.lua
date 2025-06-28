-- STUB DEFINITIONS for snacks.nvim types
---@class snacks.win
---@field winid number The Neovim window ID.
---@field bufnr number The Neovim buffer number.
---@field closed? boolean A flag indicating if the window is closed.
---@field is_open fun():boolean A method to check if the window is open.
---@field close fun() A method to close the window.
---
---@class snacks.win.Config
---@field title? string
---@field border? string
---@field width? number
---@field height? number
---@field winblend? number
---@field bo? table<string, any>

---@class snacks.terminal.Opts
---@field win? snacks.win.Config
---@field interactive? boolean
---@field on_exit? fun(snack_win: snacks.win)
---@field start_insert? boolean
---@field auto_insert? boolean
---@field auto_close? boolean
---@field env? table<string, string>
---@field shell? string | string[]
---
-- Handles the plugin's configuration.
---@class jjui.Config
---@field executable string The command to launch jjui. Assumes it's in the system's PATH.
---@field fast_shell boolean Launch the terminal with flags to skip loading shell profiles for faster startup.
---@field editor string The terminal editor to use for interactive commands like `jj describe`.
---@field terminal_opts snacks.terminal.Opts Options for the snacks.nvim terminal.

---@class jjui.config
local M = {}

---@type jjui.Config
M.options = {
	executable = "jjui",
	fast_shell = true,
	editor = "nvim",
	terminal_opts = {
		win = {
			title = "Jujutsu UI",
			border = "rounded",
			width = 0.9,
			height = 0.9,
			winblend = 0,
			bo = {
				buftype = "nofile",
			},
		},
		interactive = true,
	},
}

---@param opts jjui.Config|nil
function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
