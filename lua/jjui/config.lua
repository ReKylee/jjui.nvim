---
---@class jjui.Config
---@field executable string The command or executable to launch jjui.
---@field fast_shell boolean Launch the terminal with flags to skip loading shell profiles for faster startup.
---@field editor string The terminal editor to use for interactive commands like `jj describe`.
---@field keymaps table<string, string|false> Keymaps for the plugin.
---@field terminal_opts snacks.terminal.Opts Options for the snacks.nvim terminal.
---

---@class jjui.config
local M = {}

---@type jjui.Config
M.options = {
	executable = "jjui",
	fast_shell = true,
	editor = "nvim",
	keymaps = {
		toggle = "<leader>jj",
	},
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
