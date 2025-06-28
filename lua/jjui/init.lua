-- jjui.nvim
-- A plugin to toggle the jjui TUI using Snacks.nvim.
--
-- Author: Your Name
-- License: MIT
-- Dependencies: folke/snacks.nvim

local M = {}

-- Default configuration options.
-- This structure now aligns with the options for `Snacks.terminal.toggle`.
local config = {
	-- The command to launch jjui. Assumes it's in the system's PATH.
	executable = "jjui",
	-- Launch the terminal with flags to skip loading shell profiles for faster startup.
	fast_shell = true,
	-- The terminal editor to use for interactive commands like `jj describe`.
	-- This prevents external GUI editors (like Notepad) from opening.
	editor = "vim",

	-- Options for the snacks.nvim terminal.
	-- See `:help Snacks.terminal` for all available options.
	terminal_opts = {
		-- Window options are nested under the 'win' key.
		win = {
			title = "Jujutsu UI",
			border = "rounded",
			-- Width and height should be numbers (0.0 to 1.0) for ratios.
			width = 0.9,
			height = 0.9,
			winblend = 0,
			-- Set buffer options to prevent "save modified" prompts on exit.
			bo = {
				buftype = "nofile",
			},
		},
		-- Keep the terminal interactive (starts in insert mode, auto-closes).
		interactive = true,
	},
}

--- Creates and opens a new jjui terminal window.
local function create_new_terminal()
	-- The actual function that opens the UI using Snacks.nvim
	local function open_jjui()
		if not (Snacks and Snacks.terminal and Snacks.terminal.open) then
			vim.notify(
				"jjui.nvim requires folke/snacks.nvim to be loaded.",
				vim.log.levels.ERROR,
				{ title = "jjui.nvim" }
			)
			return
		end

		-- The base command to run.
		local command_to_run = { config.executable }
		-- Start with a fresh copy of the terminal options.
		local opts = vim.tbl_deep_extend("force", {}, config.terminal_opts)

		-- Explicitly handle the exit of the process to ensure the window always closes,
		-- even if the process crashes. This is more robust than relying on shortcuts.
		opts.on_exit = function(snack_win)
			-- The 'snack_win' object is the terminal window instance from snacks.nvim.
			-- We schedule the close to ensure it happens safely from the async callback context.
			vim.schedule(function()
				if snack_win and snack_win.is_open and snack_win:is_open() then
					-- Use close() to fully dispose of the buffer and window.
					snack_win:close()
				end
			end)
		end

		-- Since we're providing a custom on_exit, we manage the related options
		-- ourselves instead of relying on the 'interactive' shortcut to avoid conflicts.
		if opts.interactive ~= false then
			opts.start_insert = true
			opts.auto_insert = true
		end
		opts.interactive = nil -- Disable the shortcut itself.
		opts.auto_close = nil -- We handle this with our on_exit callback.

		-- Set environment variables to control the editor used by jj.
		opts.env = vim.tbl_deep_extend("force", {
			VISUAL = config.editor,
			EDITOR = config.editor,
		}, opts.env or {})

		if config.fast_shell then
			local shell_path = vim.o.shell
			local shell_name = vim.fn.fnamemodify(shell_path, ":t:l")

			-- Construct a single command line that starts the shell with no-profile
			-- flags and immediately executes the desired command.
			if shell_name:match("bash$") then
				command_to_run = { shell_path, "--noprofile", "--norc", "-c", config.executable }
			elseif shell_name:match("zsh$") then
				command_to_run = { shell_path, "--no-rcs", "-c", config.executable }
			elseif shell_name:match("fish$") then
				command_to_run = { shell_path, "--no-config", "-c", config.executable }
			elseif shell_name == "powershell.exe" or shell_name == "pwsh.exe" then
				command_to_run = { shell_path, "-NoProfile", "-Command", config.executable }
			elseif shell_name == "cmd.exe" then
				command_to_run = { shell_path, "/d", "/c", config.executable }
			end
		end

		-- Explicitly open a new terminal instead of toggling.
		Snacks.terminal.open(command_to_run, opts)
	end

	-- The function to prompt the user to initialize a new repository
	local function prompt_to_init()
		local items = {
			"Initialize a new jj repository (`jj init --git`)",
			"Initialize a colocated jj/git repository (`jj init --git --colocate`)",
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

			-- Determine the command based on the user's choice
			local init_cmd
			if choice:find("colocate") then
				init_cmd = { "jj", "init", "--git", "--colocate" }
			else
				init_cmd = { "jj", "init", "--git" }
			end

			-- User chose to initialize. Run the selected command asynchronously.
			vim.system(
				init_cmd,
				{
					cwd = vim.fn.getcwd(),
					text = true, -- Capture output as text
				},
				vim.schedule_wrap(function(init_result)
					if init_result.code == 0 then
						vim.notify(
							"Jujutsu repository initialized successfully.",
							vim.log.levels.INFO,
							{ title = "jjui.nvim" }
						)
						open_jjui() -- Now open the UI
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

	-- Check if we are in a jj repository by running `jj root`.
	vim.system(
		{ "jj", "root" },
		{
			stdout = false,
			stderr = false,
		},
		vim.schedule_wrap(function(result)
			if result.code == 0 then
				open_jjui()
			else
				prompt_to_init()
			end
		end)
	)
end

--- Toggles the visibility of the jjui floating terminal.
function M.toggle()
	if not (Snacks and Snacks.terminal and Snacks.terminal.get) then
		vim.notify("jjui.nvim requires folke/snacks.nvim to be loaded.", vim.log.levels.ERROR, { title = "jjui.nvim" })
		return
	end

	-- Explicitly check if a terminal with the executable name exists.
	-- We use `create = false` to prevent this from creating a new window.
	local term = Snacks.terminal.get(config.executable, { create = false })

	if term and term:is_open() then
		-- If the terminal is already open, close it.
		term:close()
	else
		-- If the terminal is not open, start the process to create a new one.
		create_new_terminal()
	end
end

--- The main setup function for the plugin.
--- Merges user options with the defaults.
---@param opts table|nil User-provided configuration options.
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

-- Expose internal config for testing purposes.
M._config = config

--- A function to reset config, primarily for testing.
function M.reset()
	config = {
		executable = "jjui",
		fast_shell = true,
		editor = "vim",
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
	M._config = config
end

return M
