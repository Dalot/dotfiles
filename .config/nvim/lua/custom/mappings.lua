---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },

    --  format with conform
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
        vim.diagnostic.goto_prev { float = { border = "rounded" } }
      end,
      "Goto prev",
    },

    ["<leader>e"] = {
      function()
        vim.diagnostic.goto_next { float = { border = "rounded" } }
      end,
      "Goto next",
    },
    ["<leader>tt"] = {
      function()
        require("base46").toggle_transparency()
      end,
      "Toggle transparency" },
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

-- M.nvterm = {
--   plugin = true,
-- kj
--   t = {
--     ["̱̱̱ˍ"] = {
--       function()
--         require("nvterm.terminal").toggle "horizontal"
--       end,
--       "Toggle horizontal term",
--     },
--
--   },
-- }

return M
