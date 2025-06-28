-- lua/jjui/ui.lua
--
-- Handles all UI rendering and terminal management.

---@type jjui.config
local config = require("jjui.config")

---@class jjui.ui
local M = {}

--- Opens a new jjui terminal window.
function M.open()
	if not (Snacks and Snacks.terminal and Snacks.terminal.open) then
		vim.notify("jjui.nvim requires folke/snacks.nvim to be loaded.", vim.log.levels.ERROR, { title = "jjui.nvim" })
		return
	end

	---@type string[]
	local command_to_run = { config.options.executable }

	-- Define the on_exit callback separately to prepare for table extension.
	local on_exit_callback = function(snack_win)
		vim.schedule(function()
			-- Use the `closed` field for a direct and reliable check.
			if snack_win and not snack_win.closed then
				snack_win:close()
			end
		end)
	end

	---@type snacks.terminal.Opts
	local opts = vim.tbl_deep_extend("force", {}, config.options.terminal_opts, { on_exit = on_exit_callback })

	if opts.interactive ~= false then
		opts.start_insert = true
		opts.auto_insert = true
	end
	opts.interactive = nil
	opts.auto_close = nil

	opts.env = vim.tbl_deep_extend("force", {
		VISUAL = config.options.editor,
		EDITOR = config.options.editor,
	}, opts.env or {})

	if config.options.fast_shell then
		local shell_path = vim.o.shell
		local shell_name = vim.fn.fnamemodify(shell_path, ":t:l")

		if shell_name:match("bash$") then
			command_to_run = { shell_path, "--noprofile", "--norc", "-c", config.options.executable }
		elseif shell_name:match("zsh$") then
			command_to_run = { shell_path, "--no-rcs", "-c", config.options.executable }
		elseif shell_name:match("fish$") then
			command_to_run = { shell_path, "--no-config", "-c", config.options.executable }
		elseif shell_name == "powershell.exe" or shell_name == "pwsh.exe" then
			command_to_run = { shell_path, "-NoProfile", "-Command", config.options.executable }
		elseif shell_name == "cmd.exe" then
			command_to_run = { shell_path, "/d", "/c", config.options.executable }
		end
	end

	Snacks.terminal.open(command_to_run, opts)
end

--- Closes a given terminal window.
---@param term snacks.win The snack window object to close.
function M.close(term)
	-- Use the `closed` field for a direct and reliable check.
	if term and not term.closed then
		term:close()
	end
end

return M
