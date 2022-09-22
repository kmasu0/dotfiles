vim.cmd [[
if (has("termguicolors"))
  set termguicolors
endif

set rtp+=$HOME/.fzf
set termguicolors
]]

-- init packer.nvim ------------------------------------------------------------
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- plugins ---------------------------------------------------------------------
local init_fern = function()
  vim.opt.number = false
  vim.api.nvim_buf_set_keymap(0, 'n', '<C-h>', '<Plug>(fern-action-hidden:toggle)', {})
end

local fern_id = vim.api.nvim_create_augroup('fern-custom', {})
vim.api.nvim_create_autocmd({'FileType'}, {
  pattern = 'fern',
  callback = init_fern,
  group = fern_id,
})
-- required plugins ------------------------------------------------------------
require("packer").startup(function()
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  use 'hrsh7th/cmp-vsnip'
  use 'honza/vim-snippets'

  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'
  -- use 'saadparwaiz1/cmp_luasnip'
  -- use 'quangnguyen30192/cmp-nvim-ultisnips'

  use 'lambdalisue/fern.vim'
  use 'kyazdani42/nvim-web-devicons'
  use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'windwp/nvim-autopairs'

  use 'airblade/vim-gitgutter'
  use 'mileszs/ack.vim'

  use 'mhinz/neovim-remote'
  use 'tversteeg/registers.nvim'

  use 'nvim-treesitter/nvim-treesitter'

  use 'bfrg/vim-cpp-modern'
  use 'pboettch/vim-cmake-syntax'
  use 'rhysd/vim-llvm'
  use 'habamax/vim-rst'

  -- colorscheme
  use {
    'tyrannicaltoucan/vim-deep-space'
  }
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- require('mason').setup({
--   ui = {
--       icons = {
--           package_installed = "✓",
--           package_pending = "➜",
--           package_uninstalled = "✗"
--       }
--   }
-- })
-- require('mason-lspconfig').setup_handlers({
--   function(server)
--     local opt = {
--       -- Function executed when the LSP server startup
--       on_attach = function(client, bufnr)
--         local opts = { noremap=true, silent=true }
--         vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
--         vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
--       end,
--       capabilities = require('cmp_nvim_lsp').update_capabilities(
--         vim.lsp.protocol.make_client_capabilities()
--       )
--     }
--     require('lspconfig')[server].setup(opt)
--   end
-- })
-- set up lspconfig language servers -------------------------------------------
local function on_attach(client, bufnr)
    -- Find the clients capabilities
    local cap = client.resolved_capabilities

    -- Only highlight if compatible with the language
    if cap.document_highlight then
        vim.cmd('augroup LspHighlight')
        vim.cmd('autocmd!')
        vim.cmd('autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
        vim.cmd('autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
        vim.cmd('augroup END')
    end
end

local ccls_cache_path = os.getenv('HOME')..'.cache/ccls-cache'
require'lspconfig'.ccls.setup {
  on_attach = on_attach,
  cmd = { '/opt/ccls/bin/ccls' },
  single_file_support = true,
  init_options = {
    index = { threads = 8; };
    cache = { directory = ccls_cache_path; };
  },
}
require'lspconfig'.cmake.setup{
  on_attach = on_attach,
}
require'lspconfig'.bashls.setup{
  on_attach = on_attach,
}
require'lspconfig'.rust_analyzer.setup{
  on_attach = on_attach,
}
require'lspconfig'.pylsp.setup{
  on_attach = on_attach,
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
require'lspconfig'.jsonls.setup{
  capabilities = capabilities,
  on_attach = on_attach,
}

-- hrsh7th/cmp-nvim-lsp --------------------------------------------------------
local cmp = require("cmp")
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
    { name = "vsnip" },
    { name = "buffer" },
    { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<TAB>"] = cmp.mapping.select_next_item(),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<C-k>"] = cmp.mapping.confirm { select = true },
  }),
  experimental = {
    ghost_text = true,
  },
})
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "path" },
    { name = "cmdline" },
  },
})

-- nvim-treesitter/nvim-treesitter ---------------------------------------------
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
  ensure_installed = 'all',
}
require("nvim-autopairs").setup({})
require('lualine').setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
})
require('bufferline').setup({
  options = {
    diagnostics = 'nvim_lsp',
    show_buffer_close_icons = false,
    show_close_icon = false,
    separator_style = { '|', ' ' },
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local icon = level:match("error") and " " or " "
      return " " .. icon .. count
    end,
  },
  highlights = {
    buffer_selected = {
      fg = '#fdf6e3',
      bold = true,
      italic = true,
    },
  },
})

-- keyboard shortcut ----------------------------------------------------------
vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
-- LSP handlers ----------------------------------------------------------------
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
-- Reference highlight ---------------------------------------------------------
vim.cmd [[
set updatetime=500
highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
]]
-- lambdalisue/fern.vim --------------------------------------------------------
vim.cmd [[
nnoremap <C-l> :Fern . -reveal=% -drawer -toggle -width=40<CR>
]]
-- colorscheme -----------------------------------------------------------------
vim.cmd [[
let g:cpp_class_scope_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1
let g:python_highlight_all = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

syntax enable
set termguicolors
set background=dark
let g:cpp_function_highlight = 1
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1
let g:cpp_simple_highlight = 1
autocmd ColorScheme * highlight MatchParen guibg=Red
autocmd ColorScheme * highlight Include guifg=#98C379 gui=underline
autocmd ColorScheme * highlight Comment gui=italic
autocmd ColorScheme * highligh CursorLine gui=underline guibg=none
autocmd ColorScheme * highligh CursorLineNr gui=underline guibg=none
autocmd ColorScheme * highligh ColorColumn guibg=#132739
colorscheme deep-space
set colorcolumn=80
]]
-- Other settings -------------------------------------------------------------
vim.cmd [[
set nocompatible

set nobackup
set nowritebackup
set shortmess+=c

set signcolumn=yes
set ttimeoutlen=50

" window visual
set title
set number
set numberwidth=5
" set cursorline
set nocursorline
set nocursorcolumn
set laststatus=2
set cmdheight=2
set showmatch
set ruler
" set list
" set listchars=tab:▸\ ,eol:↲,extends:»,precedes:«,nbsp:%
" set listchars=tab:▸\ 
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
]]
