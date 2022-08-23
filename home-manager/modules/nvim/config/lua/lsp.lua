local function on_attach(client, bufnr)
  -- inspect(client.resolved_capabilities)
  
  local opts = {noremap = true, silent = true}

  local function buf_set_keymap(...)
    return vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local function buf_set_option(...)
    return vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- completion
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- diagnostics
  buf_set_keymap("n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
  buf_set_keymap("n", "<C-g>", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<C-G>", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)

  -- formatting
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  else
    if client.resolved_capabilities.document_range_formatting then
      buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end
  end

  -- Go to...
  if client.resolved_capabilities.goto_definition then
    buf_set_keymap("n", "gD", "#* <cmd>lua vim.lsp.buf.definition()<cr>", opts)
  end
  if client.resolved_capabilities.declaration then
    buf_set_keymap("n", "gd", "#* <cmd>lua vim.lsp.buf.declaration()<cr>", opts)
  end
  if client.resolved_capabilities.type_definition then
    buf_set_keymap("n", "<leader>gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
  end
  if client.resolved_capabilities.implementation then
    buf_set_keymap("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
  end
  if client.resolved_capabilities.find_references then
    buf_set_keymap("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
  end

  -- Help
  if client.resolved_capabilities.hover then
    buf_set_keymap("n", "<leader>h", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
    buf_set_keymap("n", "<leader>H", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
  else
    if client.resolved_capabilities.signature_help then
      buf_set_keymap("n", "<leader>h", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    end
  end

  -- Workspaces
  if client.resolved_capabilities.workspace_folder_properties.supported then
    buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", opts)
    buf_set_keymap("n", "<leader>wl", "<cmd>lua vim.lsp.buf.list_workspace_folders()<cr>", opts)
  end

  -- Rename
  if client.resolved_capabilities.rename then
    buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
  end

  -- Highlight
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[ 
        augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> silent! lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> silent! lua vim.lsp.buf.clear_references()
        augroup END
      ]], {})
  end
end

local function capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local cmp_nvim_lsp = require("cmp_nvim_lsp")
  return cmp_nvim_lsp.update_capabilities(capabilities)
end

-- vim.lsp.set_log_level("debug")

local lspconfig = require("lspconfig")

-- ELIXIR
lspconfig.elixirls.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  cmd = {"elixir-ls"}
})

-- GDSCRIPT
lspconfig.gdscript.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  flags = {debounce_text_changes = 50}
})

-- GDSCRIPT formater
lspconfig.efm.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  filetypes = {"gdscript"}, 
  flags = {debounce_text_changes = 50}, 
  init_options = {documentFormatting = true}, 
  settings = {
    rootMarkers = {"project.godot", ".git/"}, 
    lintDebounce = 100, 
    languages = {
      gdscript = {
        formatCommand = "gdformat -l 100", 
        formatStdin = true
      }
    }
  },
  cmd = {"efm-langserver"}
})

-- ZIG
lspconfig.zls.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  cmd = {"zls"}
})

-- KOTLIN
lspconfig.kotlin_language_server.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  cmd = {"kotlin-language-server"}
})

-- NIX
lspconfig.rnix.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  cmd = {"rnix-lsp"}
})

-- C
lspconfig.clangd.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  --cmd = {"clangd --enable-config"}
  cmd = {"ccls"}
})

-- RUST
lspconfig.rust_analyzer.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  cmd = {"rust-analyzer"}
})

-- HASKELL
lspconfig.hls.setup({
  on_attach = on_attach, 
  capabilities = capabilities(), 
  cmd = {"haskell-language-server"}
})
