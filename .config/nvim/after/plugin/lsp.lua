local lsp = require("lsp-zero").preset({})
local lspconfig = require('lspconfig')

local prettier = function()
  return {
    formatCommand = "./node_modules/.bin/prettier --config-precedence=prefer-file --stdin-filepath ${INPUT}",
    formatStdin = true
  }
end

local languages = {
  javascript = { prettier() },
  javascriptreact = { prettier() },
  typescript = { prettier() },
  typescriptreact = { prettier() },
  lua = { prettier() },
  html = { prettier() },
  css = { prettier() },
  json = { prettier() },
  yaml = { prettier() },
  markdown = { prettier() },
}

local efm_filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
  "lua",
  "html",
  "css",
  "json",
  "yaml",
  "markdown"
}



lsp.ensure_installed({
  'eslint',
  'lua_ls',
  'tsserver',
  'gopls',
  'rust_analyzer',
  'clangd',
  'pyright',
  'emmet_ls',
  'tailwindcss',
  'efm'
})

lspconfig.lua_ls.setup(lsp.nvim_lua_ls(
  {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }
  }
))


local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})


lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  if client.name == 'efm' and vim.tbl_contains(efm_filetypes, vim.api.nvim_buf_get_option(bufnr, "filetype")) then
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
    vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
  end

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = false, timeout_ms = 3000 }) end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

  lsp.buffer_autoformat()
end)

lsp.format_on_save({
  format_opts = {
    async = true,
    timeout = 3000,
    tabSize = 2,
  },
})

lsp.setup()

lspconfig.efm.setup {
  on_attach = function(client)
    if not vim.tbl_contains(efm_filetypes, vim.bo.filetype) then
      vim.lsp.stop_client(client.id)
      return
    end
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentFormatting = true
    client.server_capabilities.documentRangeFormatting = true
  end,
  init_options = { documentFormatting = true, codeAction = false },
  filetypes = efm_filetypes,
  settings = {
    rootMarkers = { ".git/" },
    languages = languages
  },
}


vim.diagnostic.config({
  virtual_text = true
})
