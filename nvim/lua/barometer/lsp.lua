local cmd = vim.cmd

require("lspconfig").tsserver.setup {}

require("lspconfig").dockerls.setup {}

require("lspconfig").jsonls.setup {
  commands = {
    Format = {
      function()
        vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
      end,
    },
  },
}

require("lspconfig").vimls.setup {}

require("lspconfig").yamlls.setup {}

require("lspconfig").ocamlls.setup {}

require("lspconfig").graphql.setup {}

require("lspconfig").elixirls.setup {
  cmd = { "elixir-lsp.sh" },
}

require("lspconfig").zls.setup {}

require("lspconfig").sqlls.setup {
  cmd = { "sql-language-server", "up", "--method", "stdio" },
}

require("lspconfig").terraformls.setup {}

require("lspconfig").groovyls.setup {
  -- Unix
  cmd = { "groovy-lsp.sh" },
  filetypes = { "groovy", "jenkinsfile" },
}

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("lspconfig").html.setup {
  capabilities = capabilities,
}

require("lspconfig").sumneko_lua.setup {
  cmd = { "lua-lsp.sh" },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        },
      },
    },
  },
}

local opts = {
  -- whether to highlight the currently hovered symbol
  -- disable if your cpu usage is higher than you want it
  -- or you just hate the highlight
  -- default: true
  highlight_hovered_item = true,

  -- whether to show outline guides
  -- default: true
  show_guides = true,
}

require("symbols-outline").setup(opts)

require("compe").setup {
  enabled = true,
  autocomplete = true,
  debug = false,
  min_length = 1,
  preselect = "enable",
  throttle_time = 80,
  source_timeout = 200,
  incomplete_delay = 400,
  max_abbr_width = 100,
  max_kind_width = 100,
  max_menu_width = 100,
  documentation = true,

  source = {
    path = true,
    nvim_lsp = true,
  },
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col "." - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match "%s" then
    return true
  else
    return false
  end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn["compe#complete"]()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", { expr = true })
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", { expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", { expr = true })

--This line is important for auto-import
vim.api.nvim_set_keymap("i", "<cr>", 'compe#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap("i", "<c-space>", "compe#complete()", { expr = true })

cmd [[
augroup BAROMETER_JENKINSFILE
    au BufNewFile,BufRead Jenkinsfile setf groovy
augroup END
]]

cmd [[
augroup BAROMETER_JDTLS
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
    autocmd FileType java lua require('jdtls').start_or_attach({cmd = {'java-lsp.sh'}})
augroup END
]]
