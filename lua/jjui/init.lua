-- jjui.nvim
--
-- Main plugin file. Orchestrates the other modules.

---@type jjui.config
local config = require("jjui.config")
---@type jjui.jj
local jj = require("jjui.jj")
---@type jjui.ui
local ui = require("jjui.ui")

---@class jjui
local M = {}

--- Toggles the visibility of the jjui floating terminal.
function M.toggle()
	if not (Snacks and Snacks.terminal and Snacks.terminal.get) then
		vim.notify("jjui.nvim requires folke/snacks.nvim to be loaded.", vim.log.levels.ERROR, { title = "jjui.nvim" })
		return
	end

	-- Explicitly check if a terminal with the executable name exists.
	---@type snacks.win?
	local term = Snacks.terminal.get(config.options.executable, { create = false })

	if term and term:is_open() then
		-- If the terminal is already open, close it.
		ui.close(term)
	else
		-- If the terminal is not open, start the process to check for a repo
		-- and then create a new terminal. The final action is to open the UI.
		jj.run_with_repo_check(ui.open)
	end
end

--- The main setup function for the plugin.
---@param opts jjui.Config|nil
function M.setup(opts)
	config.setup(opts)
end

return M
