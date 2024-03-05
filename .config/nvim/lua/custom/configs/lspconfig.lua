local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
-- local telescope_conf = require("telescope.config").values
-- local action_state = require "telescope.actions.state"
-- local actions = require "telescope.actions"
local previewers = require "telescope.previewers"

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "html", "cssls", "tsserver", "clangd", "gopls", "terraform_lsp" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

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
  for _, symbol in ipairs(symbols) do
    return
    pickers
      .new({}, {
        prompt_title = "Methods",
        finder = finders.new_table {
          results = symbol,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name,
              ordinal = entry.name,
              lnum = entry.selectionRange.start.line + 1, -- Lua is 1-indexed
              path = entry.path,
            }
          end,
        },
        previewer = previewers.new_buffer_previewer {
          define_preview = function(self, _entry, _status)
            vim.api.nvim_win_set_option(self.state.winid, "wrap", true) -- return {"bat", "--style=numbers", "--color=always", filepath, "--highlight-line", tostring(entry.lnum)}
          end,
        },
        -- sorter = telescope_conf.generic_sorter({}),
        -- attach_mappings = function(prompt_bufnr, _map)
        --     actions.select_default:replace(function()
        --         local selection = action_state.get_selected_entry()
        --         actions.close(prompt_bufnr)
        --         -- Navigate to the symbol's location
        --         -- Assuming `value` contains the file path or similar to derive buffer number or file path
        --         local path = vim.uri_to_fname(selection.value.uri) -- Convert LSP URI to file path
        --         vim.cmd('e ' .. path) -- Open the file
        --         local win = vim.api.nvim_get_current_win()
        --         vim.api.nvim_win_set_cursor(win, { selection.lnum, selection.col }) -- Move cursor to symbol location
        --     end)
        --     return true
        -- end,
      })
      :find()
  end
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

  -- local symbols = {}
  -- if response then
  --   for _client_id, server_response in pairs(response) do
  --     if server_response.result then
  --       for _, symbol in ipairs(server_response.result) do
  --         symbol.path = file_path
  --         table.insert(symbols, symbol)
  --       end
  --     end
  --   end
  -- else
  --   print(vim.inspect "no result on buf_request_sync")
  --   return
  -- end
  --
  -- -- vim.lsp.buf.document_symbol({ symbols = "methods" })
  -- return symbols 
  if not response or vim.tbl_isempty(response) then
    print("LSP response is empty or nil.")
    return
  end

  -- Assuming there's only one LSP client, or you want the first one.
  -- Adjust accordingly if there are multiple clients.
  local client_id, result = next(response)
  if not result or not result.result then
    print("No result from LSP server.")
    return
  end

  local symbols = result.result
  local filtered_symbols = {}

  -- Filter for methods or any specific type of symbol you're interested in.
  -- You might need to adjust the condition depending on the symbol kind you want.
  for _, symbol in ipairs(symbols) do
    if symbol.kind == 6 then -- SymbolKind.Method == 6
      table.insert(filtered_symbols, symbol)
    end
  end

  -- Do something with `filtered_symbols`, like formatting them for display.
  -- This is a basic example; you might want to structure them more nicely.
  for _, symbol in ipairs(filtered_symbols) do
    print(symbol.name) -- Simple print; you can format it as needed.
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
    for _, symbol in ipairs(symbols) do
      table.insert(all_symbols, symbols)
    end
  end

  -- Once all symbols are collected, display them using Telescope.
  show_symbols_with_telescope(all_symbols)
end

return {
  gather_symbols_from_package = gather_symbols_from_package,
}
