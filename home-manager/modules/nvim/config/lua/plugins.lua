-- Icons for CMP
local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args) 
      vim.fn["vsnip#anonymous"](args.body) 
    end
  }, 
  window = {
    completion = cmp.config.window.bordered(), 
    documentation = cmp.config.window.bordered()
  }, 
  view = {            
    entries = "custom" -- can be "custom", "wildmenu" or "native"
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-up>'] = cmp.mapping.scroll_docs(-4),
    ['<C-down>'] = cmp.mapping.scroll_docs(4),
    ["<C-tab>"] = cmp.mapping.complete(), 
    ["<CR>"] = cmp.mapping.confirm({select = true})
    -- ['<C-c>'] = cmp.mapping.abort(),
  }), 
  sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = 'nvim_lua' },
      { name = 'nvim_lsp_signature_help' },
      { name = 'path' },
      { name = 'buffer' },
      --{ name = 'omni' },
      { name = "vsnip" }
    }, 
    {{name = "buffer"}}
  ),
  formatting = {
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      -- Source
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return vim_item
    end
  }
})

cmp.setup.cmdline('/', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})

-- FIXME: Not working like wildmenu
--cmp.setup.cmdline(':', {
--  sources = {
--    { name = 'cmdline' }
--  }
--})

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true, 
    additional_vim_regex_highlighting = true
  }, 
  incremental_selection = {
    enable = true, 
    keymaps = {
      init_selection = "gnn", 
      node_incremental = "grn", 
      scope_incremental = "grc", 
      node_decremental = "grm"}
  }, 
  indent = {
    enable = true, 
    disable = {"gdscript"} -- gdscript ident dont work
  }
})

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "<C-up>", action = "dir_up" },
        { key = "s", action = "vsplit" },
        { key = "v", action = "split" },
        { key = "?", action = "toggle_help" },
      },
    },
  },
  open_on_tab = true,
  open_on_setup = true,
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  actions = {
    change_dir = {
      -- use :cd instead of :lcd
      -- can cause issues with update_cwd
      global = true;
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
})

require("gitsigns").setup({
  numhl = true, 
  signcolumn = false, 
  current_line_blame = true, 
  attach_to_untracked = true, 
  sign_priority = 6, 
  update_debounce = 100, 
  status_formatter = nil, -- use default
  -- use_internal_diff = true,
  max_file_length = 40000, 
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single", 
    style = "minimal", 
    relative = "cursor", 
    row = 0, 
    col = 1
  }
})

require("which-key").setup({
  plugins = {
    marks = true, 
    registers = true, 
    spelling = {
      enabled = true, 
      suggestions = 20
    }
  }, 
  ignore_missings = false, 
  triggers_blacklist = {i = {"j", "k"}, v = {"j", "k"}}
})
