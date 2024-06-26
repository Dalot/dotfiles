local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local telescope_conf = require("telescope.config").values
-- local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local previewers = require "telescope.previewers"

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "gopls", "terraform_lsp", "volar"}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

require'lspconfig'.tsserver.setup{
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
        languages = {"javascript", "typescript", "vue"},
      },

    },
  },
  filetypes = {
    "javascript",
    "typescript",
    "vue",
  },

}

local function get_go_files_in_package(dir_path)
  local go_files = {}
  -- Use `io.popen` to run `go list` and capture output. Adjust the command as needed.
  local p = io.popen(string.format("go list -f '{{.GoFiles}}' %s", dir_path))
  if p ~= nil then
    local output = p:read "*all" -- Read the entire output as a single string
    p:close()

    -- Remove the enclosing brackets
    output = output:match "%[(.-)%]"

    -- Split the string into individual filenames
    for file in string.gmatch(output, "%S+") do
      table.insert(go_files, file)
    end
  end
  return go_files
end

-- Function to display symbols in Telescope
local function show_symbols_with_telescope(symbols)
  -- Get the first of symbols
  return pickers
    .new({}, {
      prompt_title = "Methods",
      finder = finders.new_table {
        results = symbols,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
            lnum = entry.selectionRange.start.line + 1, -- Lua is 1-indexed
            filename = entry.filename,
          }
        end,
      },
      -- set options in vim_buffer_cat
      previewer = previewers.vim_buffer_cat.new(telescope_conf),
      sorter = telescope_conf.generic_sorter({}),
      -- previewer = previewers.new_buffer_previewer {
      --   define_preview = function(self, entry, _status)
      --     local filepath = entry.value.path -- Ensure this path is correctly set in your symbols
      --     if filepath then
      --       -- Example command to preview the file, adjust according to your needs
      --       local bat_cmd =
      --         { "bat", "--style=numbers", "--color=always", filepath, "--highlight-line", tostring(entry.lnum) }
      --       pcall(vim.fn.jobstart, bat_cmd, {
      --         on_stdout = function(_, data)
      --           if data then
      --             self.state.bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer for the preview1
      --             vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, data)
      --             vim.api.nvim_win_set_buf(self.state.winid, self.state.bufnr)
      --           end
      --         end,
      --       })
      --     end
      --   end,
      -- },
      -- sorter = require("telescope.config").values.generic_sorter {},
    })
    :find()
end

local function get_symbols_for_file(file_path)
  -- This function needs to switch to the buffer for `file_path`, call `vim.lsp.buf.document_symbol()`,
  -- and then collect the results. This is a simplification.
  -- You might need a custom LSP request or manage buffer switching.
  local bufnr = vim.fn.bufadd(file_path)

  -- Ensure the buffer is loaded; `bufadd` does not load the buffer.
  vim.fn.bufload(bufnr)

  -- Send the document symbol request for the buffer.
  -- The LSP server must support `textDocument/documentSymbol`.
  local response = vim.lsp.buf_request_sync(
    bufnr,
    "textDocument/documentSymbol",
    { textDocument = { uri = vim.uri_from_bufnr(bufnr) }, symbols = "method" },
    1000 -- 1 second
  )

  if not response or vim.tbl_isempty(response) then
    print "LSP response is empty or nil."
    return
  end

  -- Assuming there's only one LSP client, or you want the first one.
  -- Adjust accordingly if there are multiple clients.
  local client_id, result = next(response)
  if not result or not result.result then
    print "No result from LSP server."
    return
  end

  local symbols = result.result
  local filtered_symbols = {}

  -- Filter for methods or any specific type of symbol you're interested in.
  -- You might need to adjust the condition depending on the symbol kind you want.
  for _, symbol in ipairs(symbols) do
    if symbol.kind == 6 then -- SymbolKind.Method == 6
      symbol.filename = file_path
      -- before inserting symbol into the table, check if it exists
      local exists = false
      for _, existing_symbol in ipairs(filtered_symbols) do
        if existing_symbol.name == symbol.name then
          exists = true
          break
        end
      end
      if not exists then
        table.insert(filtered_symbols, symbol)
      end
    end
  end

  return filtered_symbols
end

local function gather_symbols_from_package()
  local current_buf_file_path = vim.api.nvim_buf_get_name(0)
  local dir_path = current_buf_file_path:match "^(.*/)" or "./"
  local go_files = get_go_files_in_package(dir_path)
  local all_symbols = {}

  for _, file_name in ipairs(go_files) do
    local file_path = string.format("%s%s", dir_path, file_name)
    local symbols = get_symbols_for_file(file_path)
    if not symbols then
      return
    end
    -- unpack symbols and merge them into all_symbols
    for _, symbol in ipairs(symbols) do
      table.insert(all_symbols, symbol)
    end
  end

  -- Once all symbols are collected, display them using Telescope.
  show_symbols_with_telescope(all_symbols)
end

return {
  gather_symbols_from_package = gather_symbols_from_package,
}
