---@type MappingsTable
local M = {}

M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },

		["<leader>fm"] = {
			function()
				require("conform").format()
			end,
			"formatting",
		},

		["<leader>ri0"] = { '"_diw"0P', "replace with the register 0" },
		["<leader>r0"] = { '"_dw"0P', "replace with the register 0" },

		["<leader>fr"] = { "<cmd> Telescope resume <CR>", "   resume picker" },

		["<leader>cpe"] = { ":let @+=execute('messages') <CR>", "copy error message to clipboard" },

		["<leader>E"] = {
			function()
				vim.diagnostic.goto_prev({ float = { border = "rounded" } })
			end,
			"Goto prev",
		},

		["<leader>e"] = {
			function()
				vim.diagnostic.goto_next({ float = { border = "rounded" } })
			end,
			"Goto next",
		},
		["<leader>tt"] = {
			function()
				require("base46").toggle_transparency()
			end,
			"Toggle transparency",
		},
	},
	v = {
		[">"] = { ">gv", "indent" },
		["//"] = { "y/\\V<C-R>=escape(@\",'/')<CR><CR>", "  find selected text" },
	},
}

M.nvimtree = {
	plugin = true,

	n = {
		-- toggle
		-- this is an override
		["<C-b>"] = { "<cmd> NvimTreeToggle <CR>", "Toggle nvimtree" },
	},
}

M.harpoon = {
	n = {
		["<leader>ha"] = {
			function()
				local harpoon = require("harpoon")
				harpoon:list():append()
			end,
			"󱡁 Harpoon Add file",
		},
		["<leader>ta"] = { "<CMD>Telescope harpoon marks<CR>", "󱡀 Toggle quick menu" },
		["<leader>hb"] = {
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			"󱠿 Harpoon Menu",
		},
		["<leader>1"] = {
			function()
				local harpoon = require("harpoon")
				harpoon:list():select(1)
			end,
			"󱪼 Navigate to file 1",
		},
		["<leader>2"] = {
			function()
				local harpoon = require("harpoon")
				harpoon:list():select(2)
			end,
			"󱪽 Navigate to file 2",
		},
		["<leader>3"] = {
			function()
				local harpoon = require("harpoon")
				harpoon:list():select(3)
			end,
			"󱪾 Navigate to file 3",
		},
		["<leader>4"] = {
			function()
				local harpoon = require("harpoon")
				harpoon:list():select(4)
			end,
			"󱪿 Navigate to file 4",
		},
	},
}

M.lspconfig = {
	n = {
		["<leader>ds"] = {
			function()
				-- call lsp document_symbol but ignore everything but Methods
				vim.lsp.buf.document_symbol()
			end,
			"LSP document symbol",
		},
		["<leader>mds"] = {
			function()
				require("custom.configs.lspconfig").gather_symbols_from_package()
			end,
			"LSP document symbol",
		},
	},
}

return M
