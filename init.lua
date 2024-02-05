local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.showmatch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "nosplit"
vim.g.nowrapscan = true

-- reload file if it changed
vim.opt.autoread = true

-- spaces on tab
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- shorten messages and don't show intro
vim.opt.shortmess = "atI"

-- respect modelines
vim.opt.modeline = true

-- good indents
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
-- filetype indent on

-- better completions in command line
vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest,full"

-- always use condom! it will save your life
vim.opt.undofile = true
vim.opt.undolevels = 3000
vim.opt.undoreload = 10000
vim.opt.updatecount = 100
vim.opt.history = 2000

local prefix = vim.fn.stdpath("config") .. "/nvim"

vim.opt.undodir = prefix .. "/undo/"
vim.opt.backupdir = prefix .. "/backup/"
vim.opt.directory = prefix .. "/swap/"

vim.opt.backup = true
vim.opt.swapfile = false
vim.opt.hidden = true
vim.opt.lazyredraw = false

vim.g.mapleader = "\\"
vim.cmd("nore ; :")
vim.cmd("tnoremap <Esc> <C-\\><C-n>")

require("lazy").setup({
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},

	{ "terryma/vim-smooth-scroll" },
	{ "machakann/vim-highlightedyank" },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{
		"mhartington/oceanic-next",
		lazy = false,
		config = function()
			vim.cmd("colorschem OceanicNext")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup()
		end,
	},

	{ "mhinz/vim-startify" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"BurntSushi/ripgrep",
			"sharkdp/fd",
		},
		config = function()
			local builtin = require("telescope.builtin")
			require("telescope").load_extension("ht")
			vim.keymap.set("n", "<leader>f", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
				sync_install = false,
				highlight = {
					enable = true, -- false will disable the whole extension
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
			})
		end,
	},
	{
		"mrcjkb/haskell-tools.nvim",
		version = "^3", -- Recommended
		ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
		init = function()
			local ht = require("haskell-tools")
			local opts = { noremap = true, silent = true }
			-- haskell-language-server relies heavily on codeLenses,
			-- so auto-refresh (see advanced configuration) is enabled by default
			vim.keymap.set("n", "<space>cl", vim.lsp.codelens.run, opts)
			-- Hoogle search for the type signature of the definition under the cursor
			vim.keymap.set("n", "<space>hs", ht.hoogle.hoogle_signature, opts)
			-- Evaluate all code snippets
			vim.keymap.set("n", "<space>ea", ht.lsp.buf_eval_all, opts)
			-- Toggle a GHCi repl for the current package
			vim.keymap.set("n", "<leader>rr", ht.repl.toggle, opts)
			-- Toggle a GHCi repl for the current buffer
			vim.keymap.set("n", "<leader>rf", function()
				ht.repl.toggle(vim.api.nvim_buf_get_name(0))
			end, opts)
			vim.keymap.set("n", "<leader>rq", ht.repl.quit, opts)
		end,
	},

	{ "onsails/lspkind.nvim" },
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			local lspkind = require("lspkind")
			local cmp = require("cmp")
			cmp.setup({
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol", -- show only symbol annotations
						maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						symbol_map = { Copilot = "" },
						ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
						-- The function below will be called before any actual modifications from lspkind
						-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
						before = function(entry, vim_item)
							return vim_item
						end,
					}),
				},
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "copilot", group_index = 2 },
					{ name = "nvim_lsp" },
					-- { name = 'vsnip' }, -- For vsnip users.
					{ name = "luasnip" }, -- For luasnip users.
					-- { name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
	{
		"nvimdev/lspsaga.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lspsaga").setup({})
			vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
			vim.keymap.set("n", "gw", "<cmd>Lspsaga diagnostic_jump_next<CR>")
			vim.keymap.set("n", "<space>ca", "<cmd>Lspsaga code_action<CR>")
			local bufopts = { noremap = true, silent = true, buffer = bufnr }
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
			vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
			vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
			vim.keymap.set("n", "<space>wl", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, bufopts)
			vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
			vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
			vim.keymap.set("n", "<space>f", function()
				vim.lsp.buf.format({ async = true })
			end, bufopts)
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("trouble").setup({
				position = "right",
				width = 80,
				mode = "workspace_diagnostics",
			})
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<c-\>]],
				direction = "vertical",
				size = 40,
			})
		end,
	},
	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup({
				edit_with_instructions = {
					keymaps = {
						use_output_as_input = "<C-s>",
					},
				},
			})
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
			"nvim-telescope/telescope.nvim",
		},
	},
})
