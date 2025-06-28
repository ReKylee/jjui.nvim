-- plugin/jjui.lua
--
-- Creates the user command to interact with the jjui plugin.

-- Define the user command.
-- It's good practice to check if the command already exists.
if vim.fn.exists(":JJUI") == 0 then
	vim.api.nvim_create_user_command("JJUI", function()
		-- Lazily require the main module to improve startup time.
		require("jjui").toggle()
	end, {
		nargs = 0,
		desc = "Toggle the jjui floating terminal",
	})
end
