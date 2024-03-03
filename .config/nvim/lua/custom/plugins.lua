local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},

	{
		"stevearc/conform.nvim",
		--  for users those who want auto-save conform + lazyloading!
		-- event = "BufWritePre"
		config = function()
			require("custom.configs.conform")
		end,
	},
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
		end,
	},
	{
		-- I only use this for the fatih/go-vim
		"junegunn/fzf",
		build = "./install --bin",
	},
	{
		"fatih/vim-go",
		ft = { "go" },
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"David-Kunz/gen.nvim",
		cmd = { "Gen" },
		config = function()
			local gen = require("gen")
			gen.setup({
				model = "zephyr", -- The default model to use.
				display_mode = "split", -- The display mode. Can be "float" or "split".
				show_prompt = false, -- Shows the Prompt submitted to Ollama.
				show_model = false, -- Displays which model you are using at the beginning of your chat session.
				no_auto_close = false, -- Never closes the window automatically.
				init = function(options)
					pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
				end,
				-- Function to initialize Ollama
				command = "curl --silent --no-buffer -X POST http://localhost:11434/api/generate -d $body",
				-- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
				-- This can also be a lua function returning a command string, with options as the input parameter.
				-- The executed command must return a JSON object with { response, context }
				-- (context property is optional).
				debug = false,
			})

			gen.prompts["X_Generate_Simple_Description"] = {
				prompt = "Provide a simple and concise description of the following code:\n$register",
				replace = false,
			}

			gen.prompts["X_Generate_Description"] = {
				prompt = "Provide a detailed description of the following code:\n$register",
				replace = false,
			}

			gen.prompts["X_Suggest_Better_Naming"] = {
				prompt = "Take all variable and function names, and provide only a list with suggestions with improved naming:\n$register",
				replace = false,
			}

			gen.prompts["X_Enhance_Grammar_Spelling"] = {
				prompt = "Modify the following text to improve grammar and spelling, just output the final text in English without additional quotes around it:\n$register",
				replace = false,
			}

			gen.prompts["X_Enhance_Wording"] = {
				prompt = "Modify the following text to use better wording, just output the final text without additional quotes around it:\n$register",
				replace = false,
			}

			gen.prompts["X_Make_Concise"] = {
				prompt = "Modify the following text to make it as simple and concise as possible, just output the final text without additional quotes around it:\n$register",
				replace = false,
			}

			gen.prompts["X_Review_Code"] = {
				prompt = "Review the following code and make concise suggestions:\n```$filetype\n$register\n```",
			}

			gen.prompts["X_Enhance_Code"] = {
				prompt = "Enhance the following code, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$register\n```",
				replace = false,
				extract = "```$filetype\n(.-)```",
			}

			gen.prompts["X_Simplify_Code"] = {
				prompt = "Simplify the following code, only output the result in format ```$filetype\n...\n```:\n```$filetype\n$register\n```",
				replace = false,
				extract = "```$filetype\n(.-)```",
			}

			gen.prompts["X_Ask"] = { prompt = "Regarding the following text, $input:\n$register" }
		end,
	},
	{
		"codota/tabnine-nvim",
		build = "./dl_binaries.sh",
		lazy = false,
		config = function()
			local tabnine = require("tabnine")
			tabnine.setup({
				disable_auto_comment = true,
				accept_keymap = "<C-]>",
				dismiss_keymap = "<C-[>",
				debounce_ms = 800,
				suggestion_color = { gui = "#808080", cterm = 244 },
				exclude_filetypes = { "TelescopePrompt", "NvimTree" },
				log_file_path = nil, -- absolute path to Tabnine log file
			})
		end,
	},
	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
	-- {
	--   "mg979/vim-visual-multi",
	--   lazy = false,
	-- }
}

return plugins
