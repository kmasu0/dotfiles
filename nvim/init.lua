vim.cmd([[
if (has("termguicolors"))
  set termguicolors
endif

set rtp+=$HOME/.fzf
set termguicolors

let mapleader = "\<Space>"

if executable('rg')
  let &grepprg = 'rg --vimgrep --hidden'
endif
]])

-- init packer.nvim ------------------------------------------------------------
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local packer_bootstrap = nil
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end

-- plugins ---------------------------------------------------------------------
local init_fern = function()
  vim.opt.number = false
  vim.api.nvim_buf_set_keymap(0, "n", "<C-h>", "<Plug>(fern-action-hidden:toggle)", {})
  vim.cmd([[
  nmap <buffer> o <Plug>(fern-action-open:edit)
  nmap <buffer> s <Plug>(fern-action-open:vsplit)
  nmap <buffer> N <Plug>(fern-action-new-file)
  nmap <buffer> q :<C-u>quit<CR>'
  nmap <buffer><expr> <Plug>(fern-my-expand-or-collapse)
      \ fern#smart#leaf(
      \   "\<Plug>(fern-action-collapse)",
      \   "\<Plug>(fern-action-expand)",
      \   "\<Plug>(fern-action-collapse)",
      \ )
  nmap <buffer><nowait> l <Plug>(fern-my-expand-or-collapse)
  ]])
end

local fern_id = vim.api.nvim_create_augroup("fern-custom", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "fern",
  callback = init_fern,
  group = fern_id,
})
-- required plugins ------------------------------------------------------------
require("packer").startup(function()
  use("wbthomason/packer.nvim")
  use("neovim/nvim-lspconfig")
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-nvim-lsp-signature-help")
  use("hrsh7th/cmp-nvim-lsp-document-symbol")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/cmp-nvim-lua")
  use("hrsh7th/cmp-vsnip")

  use("j-hui/fidget.nvim")
  
  use("hrsh7th/vim-vsnip")
  use("hrsh7th/vim-vsnip-integ")
  
  use("kyazdani42/nvim-web-devicons")
  
  use("lambdalisue/fern.vim")
  use({
    "lambdalisue/fern-renderer-nerdfont.vim",
    requires = "lambdalisue/nerdfont.vim",
  })
  use({
    "lambdalisue/fern-hijack.vim",
    requires = "lambdalisue/fern.vim",
  })
  use("lambdalisue/glyph-palette.vim")
  
  use({
    "akinsho/bufferline.nvim",
    tag = "v2.*",
    requires = "kyazdani42/nvim-web-devicons",
  })
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  })
  use({
    "akinsho/toggleterm.nvim",
    tag = "*",
  })
  use({ "ibhagwan/fzf-lua", requires = { "kyazdani42/nvim-web-devicons" } })
  use("windwp/nvim-autopairs")
  use("lukas-reineke/indent-blankline.nvim")
  use("chentoast/marks.nvim")
  
  use("airblade/vim-gitgutter")
  use("mileszs/ack.vim")
  
  use("mhinz/neovim-remote")
  -- use 'tversteeg/registers.nvim'
  
  use("nvim-treesitter/nvim-treesitter")
  
  -- use("bfrg/vim-cpp-modern")
  use("pboettch/vim-cmake-syntax")
  use("rhysd/vim-llvm")
  use("habamax/vim-rst")
  use("terrortylor/nvim-comment")
  
  -- colorscheme
  use("sainnhe/sonokai")
  use("rktjmp/highlight-current-n.nvim")
  
  if packer_bootstrap then
    require("packer").sync()
  end
end)

-- hrsh7th/cmp-nvim-lsp --------------------------------------------------------
local cmp = require("cmp")
local cmp_under_fn = function(e1, e2)
  local _, e1_under = e1.completion_item.label:find "^_+"
  local _, e2_under = e2.completion_item.label:find "^_+"
  e1_under = e1_under or 0
  e2_under = e2_under or 0
  if e1_under > e2_under then
    return false
  elseif e1_under < e2_under then
    return true
  end
end
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
      -- require('luasnip').lsp_expand(args.body)
      -- require('snippy').expand_snippet(args.body)
      -- vim.fn["UltiSnips#Anon"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "nvim_lsp_document_symbol" },
    { name = "nvim_lsp_signature_help" },
    { name = "vsnip" },
    { name = "buffer" },
    { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<STAB>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<TAB>"] = cmp.mapping.select_next_item(),
    ["<C-l>"] = cmp.mapping.complete(),
    ["<C-k>"] = cmp.mapping.abort(),
    ["<C-j>"] = cmp.mapping.confirm({ select = true }),
  }),
  experimental = {
    ghost_text = true,
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp_under_fn,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
})
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "path" },
    { name = "cmdline" },
  },
})

-- initialize lspconfig --------------------------------------------------------
local diag_opts = { noremap=true, silent=true }
vim.keymap.set("n", "ge", vim.diagnostic.open_float, diag_opts)
vim.keymap.set("n", "g]", vim.diagnostic.goto_next, diag_opts)
vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, diag_opts)

local on_attach = function(client, bufnr)
  -- Find the clients capabilities
  -- local cap = client.resolved_capabilities
  local cap = client.server_capabilities
  -- Only highlight if compatible with the language
  if cap.document_highlight then
    vim.cmd("augroup LspHighlight")
    vim.cmd("autocmd!")
    vim.cmd("autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()")
    vim.cmd("autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()")
    vim.cmd("augroup END")
  end
  
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set("n", "gn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, bufopts)
  -- vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>')
  
local lsp_boarder = "double"
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = true,
  border = lsp_boarder,
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  separator = true,
  border = lsp_boarder,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { separator = true })

  vim.cmd([[
  imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
  smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
  imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
  smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
  imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
  smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
  imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
  smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
  nmap        s   <Plug>(vsnip-select-text)
  xmap        s   <Plug>(vsnip-select-text)
  nmap        S   <Plug>(vsnip-cut-text)
  xmap        S   <Plug>(vsnip-cut-text)
  ]])

  vim.cmd('command! -nargs=0 Format :lua vim.lsp.buf.format { async = true }<CR>')
end

-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- set up lspconfig language servers -------------------------------------------
local ccls_cache_path = os.getenv("HOME") .. "/.cache/ccls-cache"
local ccls_exec_path = "/opt/ccls/bin/ccls"
local util = require("lspconfig.util")
require("lspconfig").ccls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { ccls_exec_path },
  init_options = {
    index = { threads = 8 },
    cache = { directory = ccls_cache_path },
  },
  root_dir = util.root_pattern("compile_commands.json", ".ccls", ".ccls-root", ".git"),
})
require("lspconfig").cmake.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").bashls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true
      },
    }
  },
})
require("lspconfig").pylsp.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").hls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    haskell = {
      formattingProvider = 'stylish-haskell',
    },
  },
})
require("lspconfig").gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").vimls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").jsonls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
require("lspconfig").esbonio.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- j-hui/fidget.nvim -----------------------------------------------------------
require("fidget").setup({})

-- nvim-treesitter/nvim-treesitter ---------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

-- 'windwp/nvim-autopairs' -----------------------------------------------------
require("nvim-autopairs").setup({})

-- lukas-reineke/indent-blankline.nvim -----------------------------------------
vim.opt.list = true
vim.opt.listchars:append("eol:???")
require("indent_blankline").setup({
  char = "??",
  indent_level = 40,
  use_treesitter = true,
  show_trailing_blankline_indent = false,
  show_end_of_line = true,
  -- show_current_context = true,
  -- show_current_context_start = true,
})

-- 'nvim-lualine/lualine.nvim' -------------------------------------------------
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "auto",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
})

-- 'akinsho/bufferline.nvim' ---------------------------------------------------
require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = { "|", " " },
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local icon = level:match("error") and "??? " or "??? "
      return " " .. icon .. count
    end,
  },
  highlights = {
    buffer_selected = {
      fg = "#fdf6e3",
      bold = true,
      italic = false,
    },
  },
})

-- 'terrortylor/nvim-comment' --------------------------------------------------
require("nvim_comment").setup({})

-- 'akinsho/toggleterm.nvim' ---------------------------------------------------
require("toggleterm").setup({
vim.cmd([[
  autocmd TermEnter term://*toggleterm#* tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
  nnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
  inoremap <silent><c-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>
  ]]),
  direction = "float",
})

-- 'ibhagwan/fzf-lua' ----------------------------------------------------------
vim.cmd([[
  nnoremap <C-p> <cmd>lua require('fzf-lua').files()<CR>
  nnoremap <leader>fr <cmd>lua require('fzf-lua').registers()<CR>
]])

-- 'chentoast/marks.nvim' ------------------------------------------------------
require("marks").setup({
  default_mappings = false,
  mappings = {
    next = "mn",
    prev = "mp",
    toggle = "mm",
    delete_line = "dm",
  },
  vim.cmd([[nnoremap ml :MarksListBuf<CR>]])
  -- set_next               Set next available lowercase mark at cursor.
  -- toggle                 Toggle next available mark at cursor.
  -- delete_line            Deletes all marks on current line.
  -- delete_buf             Deletes all marks in current buffer.
  -- next                   Goes to next mark in buffer.
  -- prev                   Goes to previous mark in buffer.
  -- preview                Previews mark (will wait for user input). press <cr> to just preview the next mark.
  -- set                    Sets a letter mark (will wait for input).
  -- delete                 Delete a letter mark (will wait for input).
  --
  -- set_bookmark[0-9]      Sets a bookmark from group[0-9].
  -- delete_bookmark[0-9]   Deletes all bookmarks from group[0-9].
  -- delete_bookmark        Deletes the bookmark under the cursor.
  -- next_bookmark          Moves to the next bookmark having the same type as the
  --                        bookmark under the cursor.
  -- prev_bookmark          Moves to the previous bookmark having the same type as the
  --                        bookmark under the cursor.
  -- next_bookmark[0-9]     Moves to the next bookmark of of the same group type. Works by
  --                        first going according to line number, and then according to buffer
  --                        number.
  -- prev_bookmark[0-9]     Moves to the previous bookmark of of the same group type. Works by
  --                        first going according to line number, and then according to buffer
  --                        number.
  -- annotate               Prompts the user for a virtual line annotation that is then placed
  --                        above the bookmark. Requires neovim 0.6+ and is not mapped by default.
})

-- 'lambdalisue/fern.vim' ------------------------------------------------------
vim.cmd([[
  nnoremap <C-l> :Fern . -reveal=% -drawer -toggle -width=40<CR>
  let g:fern#renderer = "nerdfont"
]])

-- 'lambdalisue/glyph-palette.vim' ---------------------------------------------
vim.cmd([[
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
  autocmd FileType nerdtree,startify call glyph_palette#apply()
augroup END
]])

-- highlight/colorscheme -------------------------------------------------------
-- let g:cpp_class_scope_highlight = 1
-- let g:cpp_class_decl_highlight = 1
-- let g:cpp_concepts_highlight = 1
-- let g:cpp_function_highlight = 1
-- let g:cpp_attributes_highlight = 1
-- let g:cpp_member_highlight = 1
-- let g:cpp_simple_highlight = 1

vim.cmd([[
let g:python_highlight_all = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

set termguicolors
set background=dark
autocmd ColorScheme * hi MatchParen guibg=Red
autocmd ColorScheme * hi Include guifg=#98C379 gui=underline
autocmd ColorScheme * hi CursorLine gui=underline guibg=none
autocmd ColorScheme * hi CursorLineNr gui=underline guibg=none
autocmd ColorScheme * hi ColorColumn guibg=#132739
let g:sonokai_diagnostic_text_highlight = 1
let g:sonokai_diagnostic_line_highlight = 1
let g:sonokai_diagnostic_virtual_text = 'colored'
let g:sonokai_style = 'andromeda'
let g:sonokai_better_performance = 1 
colorscheme sonokai
set colorcolumn=80
hi LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
hi LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
hi LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
]])

-- "rktjmp/highlight-current-n.nvim" -------------------------------------------
require("highlight_current_n").setup({
  highlight_group = "IncSearch", -- highlight group name to use for highlight
})
local function _1_()
  local hcn = require("highlight_current_n")
  local feedkeys = vim.api.nvim_feedkeys
  local _2_ = vim.v.searchforward
  if (_2_ == 0) then
    return hcn.N()
  elseif (_2_ == 1) then
    return hcn.n()
  else
    return nil
  end
end

local function _4_()
  local hcn = require("highlight_current_n")
  local feedkeys = vim.api.nvim_feedkeys
  local _5_ = vim.v.searchforward
  if (_5_ == 0) then
    return hcn.n()
  elseif (_5_ == 1) then
    return hcn.N()
  else
    return nil
  end
end

vim.keymap.set("n", "n", _1_)
vim.keymap.set("n", "N", _4_)
vim.cmd([[
nmap * *N
augroup ClearSearchHL
  autocmd CmdlineLeave /,\? lua require('highlight_current_n')['/,?']()
augroup END
]])
-- Other settings --------------------------------------------------------------
vim.cmd([[
set updatetime=500
set nocompatible

set nobackup
set nowritebackup
set shortmess+=c

set mouse=

set signcolumn=yes
set ttimeoutlen=50

" window visual
set title
set number
set numberwidth=5
" set cursorline
set nocursorline
set nocursorcolumn
set laststatus=3
set cmdheight=2
set showmatch
set ruler
set showcmd

" cursor move
set scrolloff=2
set sidescroll=10
"set smartindent

" terminal
set sh=fish
autocmd TermOpen * setlocal norelativenumber
autocmd TermOpen * setlocal nonumber
tnoremap <silent> <ESC> <C-\><C-n>
tnoremap <silent> <A-c> <C-\><C-n>
nnoremap <C-j> :bnext<CR>
nnoremap <C-k> :bprev<CR>

" file process
set confirm
set noswapfile
set autoread
set nowrap

" search
set hlsearch
set incsearch
set ignorecase
set wrapscan
" set gdefault

" tab/indent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartcase
set smarttab
set matchpairs+=<:>

" commandline mode
set wildmenu wildmode=list:longest,full
set history=3000

" beap
set visualbell t_vb=
set noerrorbells

" other
" set matchpairs& matchpairs+=<:>
set infercase
set cursorline
set tags=tags

" user set command
augroup QuickFixCmd
  autocmd!
  autocmd QuickFixCmdPost *grep* cwindow
augroup END

" Enable local setting file '.vimrc.local'
function! s:vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction
" let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0

" Emacs like shorcut
" inoremap <C-k> <Right><ESC>Da
inoremap <C-d> <Del>

inoremap <C-a>  <Home>
inoremap <C-e>  <End>
inoremap <C-b>  <Left>
inoremap <C-f>  <Right>
inoremap <C-n>  <Down>
inoremap <C-p>  <UP>

inoremap <C-c> <ESC>
nnoremap gb `.zz
nnoremap <C-g> g;

" for ctags
nnoremap <C-]> g<C-]>
inoremap <C-]> <ESC>g<C-]>

" cursor shape
set guicursor=n-v-c-sm:block,i-ci:ver20-blinkon100

let g:terminal_color_0  = "#1b2b34" "black
let g:terminal_color_1  = "#ed5f67" "red
let g:terminal_color_2  = "#9ac895" "green
let g:terminal_color_3  = "#fbc963" "yellow
let g:terminal_color_4  = "#669acd" "blue
let g:terminal_color_5  = "#c695c6" "magenta
let g:terminal_color_6  = "#5fb4b4" "cyan
let g:terminal_color_7  = "#c1c6cf" "white
let g:terminal_color_8  = "#65737e" "bright black
let g:terminal_color_9  = "#fa9257" "bright red
let g:terminal_color_10 = "#343d46" "bright green
let g:terminal_color_11 = "#4f5b66" "bright yellow
let g:terminal_color_12 = "#a8aebb" "bright blue
let g:terminal_color_13 = "#ced4df" "bright magenta
let g:terminal_color_14 = "#ac7967" "bright cyan
let g:terminal_color_15 = "#d9dfea" "bright white
let g:terminal_color_background="#1b2b34" "background
let g:terminal_color_foreground="#c1c6cf" "foreground

set guifont=JetbrainsMono:h8

if exists('g:nvui')
  NvuiTitlebarFontFamily Jetbrains Mono
  NvuiTitlebarFontSize 8.0
  NvuiCmdFontFamily Jetbrains Mono
  NvuiCmdFontSize 8.0
endif
]])
