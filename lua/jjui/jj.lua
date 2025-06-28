--
-- Handles interaction with the `jj` command-line tool.
---@class jjui.jj
local M = {}

--- Prompts the user to initialize a new jj repository.
---@param on_success fun() The callback to run after successful initialization.
function M.prompt_and_init(on_success)
	vim.notify("DEBUG: Running latest jj.lua", vim.log.levels.WARN, { title = "jjui.nvim" })
	local items = {
		"Initialize a new jj/git repository (`jj git init`)",
		"Initialize a colocated jj/git repository (`jj git init --colocate`)",
		"Cancel",
	}
	vim.ui.select(items, {
		prompt = "Not a jj repository. How would you like to proceed?",
		format_item = function(item)
			return "  " .. item
		end,
	}, function(choice)
		if not choice or choice == "Cancel" then
			vim.notify("jjui aborted.", vim.log.levels.INFO, { title = "jjui.nvim" })
			return
		end

		---@type string[]
		local init_cmd
		-- This logic correctly constructs the command based on user choice.
		if choice:find("colocate") then
			init_cmd = { "jj", "git", "init", "--colocate" }
		else
			init_cmd = { "jj", "git", "init" }
		end

		vim.system(
			init_cmd,
			{
				cwd = vim.fn.getcwd(),
				text = true,
			},
			vim.schedule_wrap(function(init_result)
				if init_result.code == 0 then
					vim.notify(
						"Jujutsu repository initialized successfully.",
						vim.log.levels.INFO,
						{ title = "jjui.nvim" }
					)
					on_success() -- Run the success callback (which opens the UI)
				else
					vim.notify(
						"Failed to initialize Jujutsu repository.",
						vim.log.levels.ERROR,
						{ title = "jjui.nvim" }
					)
					if init_result.stderr and init_result.stderr ~= "" then
						vim.notify(init_result.stderr, vim.log.levels.ERROR, { title = "jj init error" })
					end
				end
			end)
		)
	end)
end

--- Checks if inside a jj repo and runs a callback, or prompts to init.
---@param on_success fun() The callback to run if already in a repo or after successful init.
function M.run_with_repo_check(on_success)
	-- Use `false` to discard output, which is the correct type for this option.
	vim.system(
		{ "jj", "root" },
		{
			stdout = false,
			stderr = false,
		},
		vim.schedule_wrap(function(result)
			if result.code == 0 then
				on_success()
			else
				M.prompt_and_init(on_success)
			end
		end)
	)
end

return M
